// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./MyMasterWarCore.sol";
import "./access/Ownable.sol";
import "./proxy/ERC721TransferProxy.sol";
import "./lifecycle/Pausable.sol";
import "./ERC/ERC20/IBEP20.sol";
import "./access/IMarketAccessManager.sol";
import "./security/ReentrancyGuard.sol";
import "./MarketV1Storage.sol";

contract MarketV1 is Ownable, Pausable, ReentrancyGuard {
    uint256 public commission; //2 decinal

    MyMasterWarCore private nft;
    IMarketAccessManager private accessManager;
    MarketV1Storage private marketV1Storage;

    event Purchase(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 nftId,
        address currency,
        uint256 listingPrice,
        uint256 price,
        uint256 sellerAmount,
        uint256 commissionAmount,
        uint256 time
    );

    event Listing(
        address indexed owner,
        uint256 indexed nftId,
        address currency,
        uint256 listingPrice,
        uint256 time
    );

    event PriceUpdate(
        address indexed owner,
        uint256 nftId,
        uint256 oldPrice,
        uint256 newPrice,
        uint256 time
    );

    event UnListing(address indexed owner, uint256 indexed nftId, uint256 time);

    constructor(
        MyMasterWarCore _nft,
        IMarketAccessManager _accessManager,
        MarketV1Storage _marketV1Storage,
        uint256 _commission
    ) {
        nft = _nft;
        accessManager = _accessManager;
        marketV1Storage = _marketV1Storage;
        commission = _commission;
    }

    function setAccessManager(IMarketAccessManager _accessManager)
        external
        onlyOwner
    {
        accessManager = _accessManager;
    }

    function setMyMasterWarCore(MyMasterWarCore _nft) external onlyOwner {
        nft = _nft;
    }

    function setStorage(MarketV1Storage _marketV1Storage) external onlyOwner {
        marketV1Storage = _marketV1Storage;
    }

    function setCommission(uint256 _commission) external onlyOwner {
        commission = _commission;
    }

    function getItem(uint256 nftId)
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256
        )
    {
        require(nft.exists(nftId), "Error, wrong nftId");

        address owner;
        address currency;
        uint256 price;
        (owner, currency, price) = marketV1Storage.getItem(nftId);
        uint256 gene;
        (, , , gene, ) = nft.get(nftId);

        return (owner, currency, price, gene);
    }

    function listing(
        uint256[] memory nftIds,
        address[] memory currencies,
        uint256[] memory prices
    ) external whenNotPaused {
        require(
            accessManager.isListingAllowed(_msgSender()),
            "Not have listing permisison"
        );

        require(nftIds.length == currencies.length, "Input invalid");
        require(nftIds.length == prices.length, "Input invalid");

        for (uint256 i = 0; i < nftIds.length; i++) {
            require(nft.exists(nftIds[i]), "Error, wrong nftId");
            require(
                nft.ownerOf(nftIds[i]) == _msgSender(),
                "Error, you are not the owner"
            );
            address owner;
            (owner, , ) = marketV1Storage.getItem(nftIds[i]);
            require(owner == address(0), "Error, item listing already");

            marketV1Storage.addItem(
                nftIds[i],
                _msgSender(),
                currencies[i],
                prices[i]
            );
            //transfer NFT for market contract
            nft.transferFrom(_msgSender(), address(this), nftIds[i]);
            emit Listing(
                _msgSender(),
                nftIds[i],
                currencies[i],
                prices[i],
                block.timestamp
            );
        }
    }

    function buy(uint256 id, uint256 amount)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        if (msg.value != 0) {
            amount = msg.value;
        }
        address owner;
        address currency;
        uint256 price;
        (owner, currency, price) = marketV1Storage.getItem(id);
        validate(id, amount, owner, currency, price);

        address previousOwner = nft.ownerOf(id);
        address newOwner = _msgSender();

        uint256 commissionAmount;
        uint256 sellerAmount;
        (commissionAmount, sellerAmount) = trade(id, currency, amount, owner);

        emit Purchase(
            previousOwner,
            newOwner,
            id,
            currency,
            price,
            amount,
            sellerAmount,
            commissionAmount,
            block.timestamp
        );
    }

    function validate(
        uint256 id,
        uint256 amount,
        address owner,
        address currency,
        uint256 price
    ) internal view {
        require(nft.exists(id), "Error, wrong nftId");
        require(owner != address(0), "Item not listed currently");
        require(_msgSender() != nft.ownerOf(id), "Can not buy what you own");
        if (currency == address(0)) {
            require(msg.value >= price, "Error, the amount is lower");
        } else {
            require(amount >= price, "Error, the amount is lower");
        }
    }

    function trade(
        uint256 id,
        address currency,
        uint256 amount,
        address nftOwner
    ) internal returns (uint256, uint256) {
        address buyer = _msgSender();

        nft.transferFrom(address(this), buyer, id);
        uint256 commissionAmount = (amount * commission) / 10000;
        uint256 sellerAmount = amount - commissionAmount;

        if (currency == address(0)) {
            payable(nftOwner).transfer(sellerAmount);
            payable(owner()).transfer(commissionAmount);
        } else {
            IBEP20(currency).transferFrom(buyer, nftOwner, sellerAmount);
            IBEP20(currency).transferFrom(buyer, owner(), commissionAmount);

            //transfer BNB back to user if currency is not address(0)
            if (msg.value != 0) {
                payable(_msgSender()).transfer(msg.value);
            }
        }

        marketV1Storage.deleteItem(id);
        return (commissionAmount, sellerAmount);
    }

    function updatePrice(uint256[] memory nftIds, uint256[] memory prices)
        public
        whenNotPaused
        returns (bool)
    {
        require(nftIds.length == prices.length, "Input invalid");
        for (uint256 i = 0; i < nftIds.length; i++) {
            address nftOwner;
            address currency;
            uint256 oldPrice;
            (nftOwner, currency, oldPrice) = marketV1Storage.getItem(nftIds[i]);

            require(_msgSender() == nftOwner, "Error, you are not the owner");
            marketV1Storage.updateItem(
                nftIds[i],
                nftOwner,
                currency,
                prices[i]
            );

            emit PriceUpdate(
                _msgSender(),
                nftIds[i],
                oldPrice,
                prices[i],
                block.timestamp
            );
        }

        return true;
    }

    function unListing(uint256[] memory nftIds)
        public
        whenNotPaused
        returns (bool)
    {
        for (uint256 i = 0; i < nftIds.length; i++) {
            address nftOwner;
            (nftOwner, , ) = marketV1Storage.getItem(nftIds[i]);
            require(_msgSender() == nftOwner, "Error, you are not the owner");

            marketV1Storage.deleteItem(nftIds[i]);

            nft.transferFrom(address(this), _msgSender(), nftIds[i]);

            emit UnListing(_msgSender(), nftIds[i], block.timestamp);
        }

        return true;
    }
}
