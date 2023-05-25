// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

import "blockchain/contracts/Polygon/ERC20Standards/Tokens/SimpleToken.sol" as SimpleTokenContract;
import "blockchain/contracts/Polygon/Finance/Medium.sol";

interface ISingleState {
    event NewFundCreated(
        address indexed creator,
        string identifier,
        address[] managers,
        address simpleToken,
        uint256 initialBalance,
        uint256 initialSupply
    );
}

contract SingleState is Initializable, PausableUpgradeable, OwnableUpgradeable {

    uint256 priceToCreateNewFund;
    uint256 feeToContribute;
    uint256 feeToWithdraw;

    uint256 numberOfPools;

    struct CollatTSchedule {
        uint64 startTimestamp;
        uint32 remainingTimeInSeconds;
        uint256 collateral;
        bool complete;
    }

    struct FundingSchedule {
        uint64 startTimestamp;
        uint32 durationInSeconds;
        uint256 required;
        bool isWhitelisted;
        bool success;
    }

    struct Fund {
        uint256 no;
        string identifier;
        SimpleTokenContract.SimpleToken simpleToken;
        FundingSchedule fundingSchedule;
        uint256 balance;
        address[] contractsOfTokens;
        uint256[] amountOfTokens;
        CollatTSchedule[] collatTSchedules;
    }

    mapping(uint256 => Fund) internal funds;

    struct Account {
        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;
    }

    mapping(address => Account) internal accounts;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Pausable_init();
        __Ownable_init();
    }

    function _newFundingSchedule(
        uint64 startTimestamp,
        uint32 durationInSeconds,
        uint256 required,
        bool isWhitelisted,
        bool success
    ) internal returns (FundingSchedule) {
        FundingSchedule newFundingSchedule = FundingSchedule();
        newFundingSchedule.startTimestamp = startTimestamp;
        newFundingSchedule.durationInSeconds = durationInSeconds;
        newFundingSchedule.required = required;
        newFundingSchedule.isWhitelisted = isWhitelisted;
        newFundingSchedule.success = success;
        return newFundingSchedule;
    }

    function _newSimpleToken(
        string memory nameOfToken,
        string memory symbolOfToken
    ) internal returns (SimpleTokenContract.SimpleToken) {
        SimpleTokenContract.SimpleToken newSimpleToken = new SimpleTokenContract.SimpleToken(
            nameOfToken,
            symbolOfToken
        );
        return newSimpleToken;
    }

    function _newFund(
        string memory identifier,
        address[] memory managers,
        SimpleTokenContract.SimpleToken memory simpleToken,
        FundingSchedule memory newFundingSchedule,
        uint256 balance
    ) internal returns (Fund) {
        numberOfPools += 1;
        Fund newFund = Fund();
        newFund.no = numberOfPools;
        newFund.identifier = identifier;
        newFund.simpleToken = simpleToken;
        newFund.fundingSchedule = newFundingSchedule;
        newFund.balance = balance;

        for (uint256 i = 0; i < managers.length; i++) {
            Account memory caller = accounts[managers[i]];
            caller.isManager[newFund.no] = true;
            accounts[msg.sender] = caller;
        }

        emit NewFundCreated(
            msg.sender,
            identifier,
            managers,
            address(simpleToken),
            balance,
            simpleToken.totalSupply()
        );

        return Fund;
    }

    function _isAdminOf(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isAdmin[no]) {return true;}
        return false;
    }

    function _isCreatorOf(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isCreator[no]) {return true;}
        return false;
    }

    function _isManagerOf(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isManager[no]) {return true;}
        return false;
    }

    function _isOnWhitelistOf(uint256 no) internal returns (bool) {
        Account memory caller = accounts[msg.sender];
        if (caller.isOnWhitelist[no]) {return true;}
        return false;
    }

    function _getNetAssetValueOf(
        address oracle,
        uint256 no,
        uint256 currency
    ) internal returns (uint256) {
        IMedium medium = IMedium(oracle);
        bytes memory args;
        uint256 price;
        uint256 amount;
        uint256 sum;
        for (uint256 i = 0; i < contractsOfTokens.length; i++) {
            contract_ = contractsOfTokens[i];
            args = abi.encode(currency, contract_);
            (, price) = medium.getPrice(args);
            amount = amountOfTokens[i];
            sum += price * amount;
        }
        return sum;
    }

    function createNewFund(bytes memory args) public payable nonReentrant onlyOwner returns (bool) {
        (
            string memory identifier,
            address[] memory managers,
            uint32 durationInSeconds,
            uint256 required,
            bool isWhitelisted,
            string memory nameOfToken,
            string memory symbolOfToken,
            uint256 initialSupply,
            address nativeToken,
            address safe
        ) = abi.decode(
            args, 
            (
                string,
                uint32,
                uint256,
                bool,
                string,
                string,
                address,
                address
            )
        );

        /** moderation */
        require(durationInSeconds >= 24 hours, "SingleState::createNewFund: durationInSeconds < 24 hours");
        require(required >= 0, "SingleState::createNewFund: required < 0");
        require(initialSupply >= 0, "SingleState::createNewFund: initialSupply < 0");
        require(initialSupply <= type(uint256).max, "SingleState::createNewFund: initialSupply > type(uint256).max");
        require(nativeToken != address(0x0), "SingleState::createNewFund: nativeToken == address(0x0)");
        require(safe != address(0x0), "SingleState::createNewFund: safe == address(0x0)");
        require(msg.value >= 1, "SingleState::createNewFund: msg.value < 1 wei"); 
        require(numberOfPools <= type(uint256).max, "SingleState::createNewFund: numberOfPools > type(uint256).max");

        // monetisation
        if (priceToCreateNewFund > 0) {
            IERC20(nativeToken).transferFrom(
                msg.sender,
                safe,
                priceToCreateNewFund
            );
        }

        uint256 value = msg.value;

        funds[numberOfPools] = _newFund(
            identifier,
            managers,
            _newSimpleToken(
                nameOfToken,
                symbolOfToken
            ),
            _newFundingSchedule(
                block.timestamp,
                durationInSeconds,
                required,
                isWhitelisted,
                false
            ),
            value
        );

        funds[numberOfPools].simpleToken.mint(msg.sender, initialSupply);
    }
}