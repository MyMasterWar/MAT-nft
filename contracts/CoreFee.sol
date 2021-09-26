// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./access/Ownable.sol";
import "./ERC/ERC20/IBEP20.sol";

contract CoreFee is Ownable {
    IBEP20 public feeContract;
    uint256 public bornFee;
    uint256 public evolveFee;
    uint256 public breedFee;
    uint256 public destroyFee;

    constructor(IBEP20 _feeContract) {
        feeContract = _feeContract;
    }

    function setBornFee(uint256 _bornFee) public onlyOwner {
        bornFee = _bornFee;
    }

    function setEvolveFee(uint256 _evolveFee) public onlyOwner {
        evolveFee = _evolveFee;
    }

    function setBreedFee(uint256 _breedFee) public onlyOwner {
        breedFee = _breedFee;
    }

    function setDestroyFee(uint256 _destroyFee) public onlyOwner {
        destroyFee = _destroyFee;
    }

    function chargeBornFee(
        address _toAddress,
        uint256 _nftId,
        uint256 _gene
    ) external {
        if (bornFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        feeContract.transferFrom(_toAddress, owner(), bornFee);
    }

    function chargeEvolveFee(
        address _toAddress,
        uint256 _nftId,
        uint256 _newGene
    ) external {
        if (evolveFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        feeContract.transferFrom(_toAddress, owner(), evolveFee);
    }

    function chargeBreedFee(
        address _toAddress,
        uint256 _nftId1,
        uint256 _nftId2,
        uint256 _newGene
    ) external {
        if (breedFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        feeContract.transferFrom(_toAddress, owner(), breedFee);
    }

    function chargeDestroyFee(address _toAddress, uint256 _nftId) external {
        if (destroyFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        feeContract.transferFrom(_toAddress, owner(), destroyFee);
    }
}
