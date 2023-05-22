// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

/**
* version 0.1.0 SingleState: massive optimizations in speed and more
 */

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

import "blockchain/contracts/Polygon/Pools/Prototype/Utils.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/SimpleToken.sol" as SimpleTokenContract;
import "blockchain/contracts/Polygon/Finance/Oracle.sol";

contract SingleState is Initializable, PausableUpgradeable, OwnableUpgradeable {
    uint256 priceToCreateNewFund;
    uint256 feeToContribute;
    uint256 feeToWithdraw;
    address dreamToken;
    address payable safe;
    uint256 numberOfPools;
    
    struct Fund {
        /** meta */
        uint256 no;
        string name;
        string description;
        /** initial funding schedule */
        GenesisCapitalSchedule genesisCapitalSchedule;
        /** unique token contract */
        SimpleTokenContract.SimpleToken simpleToken;
        /** accounting */
        uint256 balance;                /** balance in MATIC */
        address[] contractsOfTokens;
        uint256[] amountOfTokens;
        /** managers collateralized transfers */
        CollateralTransferSchedule[] collateralTransferSchedule;
    /** initial funding schedule for a fund */
    } struct GenesisCapitalSchedule {
        uint64 startTimestamp;
        uint32 durationInSeconds;
        uint256 required;
        bool isWhitelisted;
        bool success;
    /** collateral transder schedule for a fund */
    } struct CollateralTransferSchedule {
        uint64 startTimestamp;
        uint32 remainingTimeInSeconds;
        uint256 collateral;             /** collateral in matic */
        bool complete;
    }

    mapping (uint256 => Fund) internal funds;
    /** account information */
    struct Account {
        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;
    }

    mapping (address => Account) internal accounts;

    /** @custom:oz-upgrades-unsafe-allow contructor */
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Pausable_init();
        __Ownable_init();
    }

    /*---------------------------------------------------------------- PRIVATE **/
    function _copyArray(uint256[] memory source) internal pure returns (uint256[] memory) {
        uint256[] memory destination = new uint256[](source.length);

        for (uint256 i = 0; i < source.length; i++) {
            destination[i] = source[i];
        }

        return destination;
    }

    function _newGenesisCapitalSchedule(
        uint64 startTimestamp_,
        uint32 durationInSeconds_,
        uint256 required_,
        bool isWhitelisted_,
        bool success_
    ) internal returns (GenesisCapitalSchedule) {
        return GenesisCapitalSchedule({
            startTimestamp: startTimestamp_,
            durationInSeconds: durationInSeconds_,
            required: required_,
            isWhitelisted: isWhitelisted_,
            success: success_
        });
    }

    function _newCollateralTransferSchedule(
        uint64 startTimestamp_,
        uint32 remainingTimeInSeconds_,
        uint256 collateral_,
        bool complete_
    ) internal returns (CollateralTransferSchedule) {
        return CollateralTransferSchedule({
            startTimestamp: startTimestamp_,
            remainingTimeInSeconds: remainingTimeInSeconds_,
            collateral: collateral_,
            complete: complete_
        });
    }

    function _newFund(
        uint256 no_,
        string memory name_,
        string memory description_,
        GenesisCapitalSchedule memory genesisCapitalSchedule_,
        SimpleTokenContract.SimpleToken memory simpleToken_,
        uint256 balance_,
        address[] contractsOfTokens_,
        uint256[] amountOfTokens_
    ) internal returns (Fund) {
        return Fund({
            no: no_,
            name: name_,
            description: description_,
            genesisCapitalSchedule: genesisCapitalSchedule_,
            simpleToken: simpleToken_,
            balance: balance_,
            contractsOfTokens: contractsOfTokens_,
            amountOfTokens: amountOfTokens_,
            collateralTransferSchedule: []
        });
    }
    /** because we are working with bytes must use this */
    function _isAdminFor(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isAdmin[no]) {return true;}
        return false;
    }

    function _isCreatorFor(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isCreator[no]) {return true;}
        return false;
    }

    function _isManagerFor(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isManager[no]) {return true;}
        return false;
    }

    function _isOnWhitelistFor(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isOnWhitelist[no]) {return true;}
        return false;
    }

    function _getNetAssetValueOf(address oracle, uint256 no) internal returns (uint256) {
        Fund memory fund = funds[no];
        uint256 sum;

        if (fund.contractsOfTokens.length != fund.amountOfTokens.length) {
            /** it means we've messed up somewhere big time */
        }
        
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}