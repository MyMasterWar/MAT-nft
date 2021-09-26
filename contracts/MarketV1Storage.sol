// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./access/Ownable.sol";

contract MarketV1Storage is Ownable {
    struct Item {
        address owner;
        address currency;
        uint256 price;
    }
    mapping(uint256 => Item) public items;
    mapping(address => bool) whilelists;

    modifier onlyWhilelist() {
        require(whilelists[_msgSender()], "Storage: only whilelist");
        _;
    }

    function setWhilelist(address _user, bool _isWhilelist) external {
        whilelists[_user] = _isWhilelist;
    }

    function addItem(
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price
    ) public onlyWhilelist {
        items[_nftId] = Item(_owner, _currency, _price);
    }

    function addItems(
        uint256[] memory _nftIds,
        address[] memory _owners,
        address[] memory _currencies,
        uint256[] memory _prices
    ) external onlyWhilelist {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            addItem(_nftIds[i], _owners[i], _currencies[i], _prices[i]);
        }
    }

    function deleteItem(uint256 _nftId) public onlyWhilelist {
        delete items[_nftId];
    }

    function deleteItems(uint256[] memory _nftIds) external onlyWhilelist {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            deleteItem(_nftIds[i]);
        }
    }

    function updateItem(
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price
    ) external onlyWhilelist {
        items[_nftId] = Item(_owner, _currency, _price);
    }

    function getItem(uint256 _nftId)
        external
        view
        returns (
            address,
            address,
            uint256
        )
    {
        return (
            items[_nftId].owner,
            items[_nftId].currency,
            items[_nftId].price
        );
    }
}
