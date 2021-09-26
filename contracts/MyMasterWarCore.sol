// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC/ERC721/ERC721.sol";
import "./access/Ownable.sol";
import "./access/IMATAccessManager.sol";
import "./CoreFee.sol";

contract MyMasterWarCore is ERC721, Ownable {
    uint256 public currentId;
    IMATAccessManager MATAccessManager;
    CoreFee coreFee;
    struct MyMasterWar {
        uint256 parent1;
        uint256 parent2;
        uint256 gene;
        uint256 bornAt;
    }
    mapping(uint256 => MyMasterWar) myMasterWars;
    // MyMasterWar[] myMasterWars;

    event Born(
        address indexed caller,
        address indexed to,
        uint256 indexed nftId,
        uint256 gene,
        uint256 time
    );
    event Evolve(
        address indexed caller,
        uint256 indexed nftID,
        uint256 oldGene,
        uint256 newGene,
        uint256 time
    );
    event Breed(
        address indexed caller,
        address indexed to,
        uint256 indexed newNftId,
        uint256 parent1,
        uint256 parent2,
        uint256 newGene,
        uint256 time
    );
    event Destroy(address indexed caller, uint256 indexed nftId, uint256 time);

    constructor(IMATAccessManager _MATAccessManager, CoreFee _coreFee)
        ERC721("mymasterwar.com", "MAT721")
    {
        MATAccessManager = _MATAccessManager;
        coreFee = _coreFee;
        currentId = 1;
    }

    function setMATAccessManager(IMATAccessManager _MATAccessManager)
        public
        onlyOwner
    {
        MATAccessManager = _MATAccessManager;
    }

    function setCoreFee(CoreFee _coreFee) public onlyOwner {
        coreFee = _coreFee;
    }

    function born(address _toAddress, uint256 _gene) public {
        require(
            MATAccessManager.isBornAllowed(_msgSender(), _gene),
            "Not have born permisison"
        );
        uint256 _nftId = currentId;

        _mint(_toAddress, _nftId);
        myMasterWars[_nftId] = MyMasterWar(0, 0, _gene, block.timestamp);

        //charge fee
        coreFee.chargeBornFee(_toAddress, _nftId, _gene);

        emit Born(_msgSender(), _toAddress, _nftId, _gene, block.timestamp);

        currentId = currentId + 1;
        // return _nftId;
    }

    function borns(address[] calldata _toAddresses, uint256[] calldata _genes)
        public
    {
        require(_toAddresses.length == _genes.length, "Invalid input");

        for (uint256 i = 0; i < _toAddresses.length; i++) {
            born(_toAddresses[i], _genes[i]);
            // ids.push(id);
        }
        // return ids;
    }

    function evolve(uint256 _nftId, uint256 _newGene) external {
        require(
            MATAccessManager.isEvolveAllowed(_msgSender(), _newGene, _nftId),
            "Not have evolve permisison"
        );
        require(ownerOf(_nftId) != address(0), "NFT id invalid");

        uint256 oldGene = myMasterWars[_nftId].gene;
        require(oldGene != _newGene, "Gene not change");

        myMasterWars[_nftId].gene = _newGene;

        //charge fee
        // coreFee.chargeEvolveFee(_msgSender(), _nftId, _newGene);
        emit Evolve(_msgSender(), _nftId, oldGene, _newGene, block.timestamp);
    }

    function breed(
        address _toAddress,
        uint256 _nftId1,
        uint256 _nftId2,
        uint256 _gene
    ) external returns (uint256) {
        require(
            MATAccessManager.isBreedAllowed(_msgSender(), _nftId1, _nftId2),
            "Not have breed permisison"
        );
        require(ownerOf(_nftId1) != address(0), "NFT 1 invalid");
        require(ownerOf(_nftId2) != address(0), "NFT 2 invalid");

        // uint256 _nftId = totalSupply() + 1;
        uint256 _nftId = currentId;

        _mint(_toAddress, _nftId);
        myMasterWars[_nftId] = MyMasterWar(
            _nftId1,
            _nftId2,
            _gene,
            block.timestamp
        );

        currentId = currentId + 1;

        //charge fee
        // coreFee.chargeBreedFee(_toAddress, _nftId1, _nftId2, _gene);
        emit Breed(
            _msgSender(),
            _toAddress,
            _nftId,
            _nftId1,
            _nftId2,
            _gene,
            block.timestamp
        );
        return _nftId;
    }

    function destroy(uint256 _nftId) external {
        require(
            MATAccessManager.isDestroyAllowed(_msgSender(), _nftId),
            "Not have destroy permisison"
        );
        _burn(_nftId);
        delete myMasterWars[_nftId];

        //charge fee
        // coreFee.chargeDestroyFee(_msgSender(), _nftId);
        emit Destroy(_msgSender(), _nftId, block.timestamp);
    }

    function exists(uint256 _id) public view returns (bool) {
        return _exists(_id);
    }

    function get(uint256 _nftId)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            ownerOf(_nftId),
            myMasterWars[_nftId].parent1,
            myMasterWars[_nftId].parent2,
            myMasterWars[_nftId].gene,
            myMasterWars[_nftId].bornAt
        );
    }
}
