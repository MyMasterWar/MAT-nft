// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./access/Ownable.sol";
import "./ERC/ERC20/IBEP20.sol";
import "./ERC/ERC20/SafeBEP20.sol";

contract CoreFee is Ownable {
    using SafeBEP20 for IBEP20;
    IBEP20 public feeContract;
    address public myMasterWarCore;
    uint256 public bornFee;
    uint256 public evolveFee;
    uint256 public breedFee;
    uint256 public destroyFee;

    //CoreFee have to deploy before MyMasterWarCore, so will set MyMasterWarCore later on
    constructor(IBEP20 _feeContract) {
        require(address(_feeContract) != address(0), "Error: address(0)");
        feeContract = _feeContract;
    }

    modifier onlyMaMasterWarCore() {
        require(_msgSender() == myMasterWarCore, "Error: Not MyMasterWarCore");
        _;
    }

    function setMyMasterWarCore(address _myMasterWarCore) external onlyOwner {
        require(myMasterWarCore != address(0), "Error: address(0)");
        myMasterWarCore = _myMasterWarCore;
    }

    function setFeeContract(IBEP20 _feeContract) external onlyOwner {
        require(address(_feeContract) != address(0), "Error: address(0)");
        feeContract = _feeContract;
    }

    function setBornFee(uint256 _bornFee) external onlyOwner {
        bornFee = _bornFee;
    }

    function setEvolveFee(uint256 _evolveFee) external onlyOwner {
        evolveFee = _evolveFee;
    }

    function setBreedFee(uint256 _breedFee) external onlyOwner {
        breedFee = _breedFee;
    }

    function setDestroyFee(uint256 _destroyFee) external onlyOwner {
        destroyFee = _destroyFee;
    }

    function chargeBornFee(
        address _toAddress,
        uint256 _nftId,
        uint256 _gene
    ) external onlyMaMasterWarCore {
        if (bornFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), bornFee);
        feeContract.safeTransferFrom(_toAddress, owner(), bornFee);
    }

    function chargeEvolveFee(
        address _toAddress,
        uint256 _nftId,
        uint256 _newGene
    ) external onlyMaMasterWarCore {
        if (evolveFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), evolveFee);
        feeContract.safeTransferFrom(_toAddress, owner(), evolveFee);
    }

    function chargeBreedFee(
        address _toAddress,
        uint256 _nftId1,
        uint256 _nftId2,
        uint256 _newGene
    ) external onlyMaMasterWarCore {
        if (breedFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), breedFee);
        feeContract.safeTransferFrom(_toAddress, owner(), breedFee);
    }

    function chargeDestroyFee(address _toAddress, uint256 _nftId)
        external
        onlyMaMasterWarCore
    {
        if (destroyFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), destroyFee);
        feeContract.safeTransferFrom(_toAddress, owner(), destroyFee);
    }
}
