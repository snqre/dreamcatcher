// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/Pausable.sol";
import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/IERC20.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";
import "extensions/mirai/smart_contracts/polygon/tokens/standard_token/StandardToken.sol";

library QuickSwapLogicLib {
    function getLiquidity() public view returns (uint) {
        /// returns the amount of liquidity in a pair.
    }

    function getPrice() public view returns (uint) {
        /// checks the exchange rate on quickswap.
    }
}

interface IPools {
    event PoolCreated(
        string indexed name,
        uint indexed identifier,
        address contractOfToken,
        address[] managers,
        address[] admins,
        string nameOfToken,
        string symbolOfToken
    );

    event PoolSetup(
        string indexed name,
        uint indexed identifier,
        uint startTimestamp,
        uint endTimestamp,
        uint duration,
        uint required,
        address[] whitelist
    );
}

contract Pools is IPools, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    uint public numberOfPools;

    struct FundingSchedule {
        uint startTimestamp;
        uint endTimestamp;
        uint duration;
        uint required;
        bool isWhitelisted;
        bool hasBeenPassed;
        bool hasBeenCancelled;
        bool hasBeenCompleted;
        EnumerableSet
            .AddressSet whitelist;
        bool hasBeenSetup;
    }

    struct CollatTSchedule {
        uint startTimestamp;
        uint endTimestamp;
        uint duration;
        uint guarantee;
        bool hasBeenCancelled;
        bool hasBeenCompleted;
    }

    struct Vault { /// in built vault.
        EnumerableSet.AddressSet contracts;
        EnumerableSet.UintSet amounts;
        uint balance;
    }

    struct Pool {
        uint identifier;
        string name;
        address creator;
        FundingSchedule fundingSchedule;
        CollatTSchedule[] collatTSchedules;
        Vault vault;
        bool hasBeenPaused;
        EnumerableSet
            .AddressSet managers;
        EnumerableSet
            .AddressSet admins;
        StandardToken token;
        address contractOfToken;
    }

    struct Gas {
        uint create;
        uint setup;
        uint contribute;
        uint withdrawAfterLockup;
        uint withdrawAfterFailedFundingSchedule;
    }

    struct Settings {
        uint minFundingDuration;
        uint maxFundingDuration;
        uint lockupDuration;
        Gas gas;
    }

    Settings public settings;
    mapping(string => address) public contracts;
    mapping(uint => Pool) private _pools;
    mapping(string => uint) public nameToIdentifier;

    modifier onlyIfNoExistingMatch(string memory name) {
        require(
            nameToIdentifier[name] == 0,
            "Match found."
        );
        _;
    }

    modifier onlyIfExistingMatch(string memory name) {
        require(
            nameToIdentifier[name] != 0,
            "Match not found."
        );
        _;
    }

    modifier onlyIfFundingScheduleHasBeenSetup(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            pool.fundingSchedule.hasBeenSetup,
            "Cannot perform this action until setup."
        );
        _;
    }

    modifier onlyIfFundingScheduleHasNotBeenCancelled(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            !pool.fundingSchedule.hasBeenCancelled,
            "Funding schedule has been cancelled."
        );
        _;
    }

    modifier onlyIfFundingScheduleHasBeenCancelled(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            pool.fundingSchedule.hasBeenCancelled,
            "Funding schedule has not been cancelled."
        );
        _;
    }

    modifier onlyIfFundingScheduleHasNotBeenCompleted(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            !pool.fundingSchedule.hasBeenCompleted,
            "Funding schedule has been completed."
        );
        _;
    }

    modifier onlyManagerOf(string memory name) {
        Pool storage pool = _pools[nameToIdentifer[name]];
        require(
            pool.managers.contains(msg.sender),
            "Caller is not a manager."
        );
        _;
    }

    modifier onlyAdminOf(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            pool.admins.contains(msg.sender),
            "Caller is not an admin."
        );
        _;
    }

    modifier onlyWhitelist(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        if (pool.isWhitelisted) {
            require(
                pool.whitelist.contains(msg.sender),
                "Caller is not on whitelist."
            );
        }
        _;
    }

    modifier onlyAfterLockupDuration(string memory name) {
        Pool storage pool = _pools[nameToIdentifer[name]];
        uint lockupEndTimestamp = pool.fundingSchedule.startTimestamp + settings.lockupDuration;
        require(
            block.timestamp >= lockupEndTimestamp,
            "Cannot perform this action before lockup duration has ended."
        );
        _;
    }

    modifier onlyAfterFundingScheduleEnd(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            block.timestamp >= pool.fundingSchedule.endTimestamp,
            "Cannot perform this action before funding schedule has ended."
        );
        _;
    }

    modifier onlyBeforeFundingScheduleEnd(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            block.timestamp < pool.fundingSchedule.endTimestamp,
            "Cannot perform this action after funding schedule has ended."
        );
        _;
    }

    modifier onlyAfterFundingScheduleStart(string memory name) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        require(
            block.timestamp >= pool.fundingSchedule.startTimestamp,
            "Cannot perform this action before funding schedule has started."
        );
        _;
    }

    modifier monetize(uint value) {
        IERC20 token = IERC20(contracts["dream"]);
        require(
            token.balanceOf(msg.sender) >= value,
            "Insufficient balance."
        );
        _;

        /// get the latest implementation of the vault.
        bool success = token.transferFrom(
            msg.sender,
            IModuleManager(contracts["module-manager"]).getLatestImplementation("vault"),
            value
        );

        require(success);
        _;
    }

    constructor(
        address dreamToken,
        address moduleManager
    ) Ownable() {
        _transferOwnership(msg.sender);
        /// quickswaps uniswap v2 router fork as specified on https://github.com/QuickSwap/quickswap-core/tree/master.
        contracts["quickswap-v2-router"] = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
        contracts["matic"] = 0x0000000000000000000000000000000000001010;
        contracts["weth"] = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
        contracts["usdc"] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        contracts["usdt"] = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
        contracts["dream"] = dreamToken;
        contracts["module-manager"] = moduleManager;

        settings.minFundingDuration = 1 weeks;
        settings.maxFundingDuration = 9 weeks;
        settings.lockupDuration = 4 weeks;

        settings.gas.create = _converToWei(1);
        settings.gas.setup = _converToWei(1);
        settings.gas.contribute = _converToWei(1);
        settings.gas.withdrawAfterLockup = _converToWei(1);
        settings.gas.withdrawAfterFailedFundingSchedule = _converToWei(1);
    }

    function _convertToWei(uint value)
    internal pure
    returns (uint) {
        return value * 10**18;
    }

    function _amountToMint(
        uint v,
        uint s,
        uint b
    ) internal pure
    returns (uint) {
        require(v >= _convertToWei(1), "v < 10000000000000000000000000000.");
        require(s >= _convertToWei(1), "s < 10000000000000000000000000000.");
        require(b >= _convertToWei(1), "b < 10000000000000000000000000000.");

        return ((v * s) / b);
    }

    function _amountToSend(
        uint v,
        uint s,
        uint b
    ) internal pure
    returns (uint) {
        require(v >= _convertToWei(1), "v < 10000000000000000000000000000.");
        require(s >= _convertToWei(1), "s < 10000000000000000000000000000.");
        require(b >= _convertToWei(1), "b < 10000000000000000000000000000.");

        return ((v * b) / s);
    }

    function _withdraw(
        string memory name,
        uint amount
    ) internal 
    returns (bool) {
        Pool storage pool = _pools[nameToIdentifier[name]];

        require(
            pool.token.balanceOf(msg.sender) >= amount,
            "Insufficient balance."
        );

        address payable to = payable(msg.sender);
        to.transfer(_amountToSend(
            amount,
            pool.token.totalSupply(),
            pool.vault.balance
        ));
    }

    /// can withdraw if funding schedule is still ongoing and lockup duration is over.
    function _withdrawAfterLockup(
        string memory name,
        uint amount
    ) internal
    onlyIfFundingScheduleHasNotBeenCompleted(name)
    onlyAfterLockupDuration(name)
    returns (bool) {
        return _withdraw(
            name,
            amount
        );
    }

    /// can withdraw if funding schedule has ended and not been completed.
    function _withdrawAfterFailedFundingSchedule(
        string memory name,
        uint amount
    ) internal
    onlyIfAfterFundingScheduleEnd(name)
    onlyIfFundingScheduleHasNotBeenCompleted(name)
    returns (bool) {
        return _withdraw(
            name,
            amount
        );
    }

    /// can withdraw if funding schedule has been cancelled.
    function _withdrawAfterCancellation(
        string memory name,
        uint amount
    ) internal
    onlyIfFundingScheduleHasBeenCancelled(name)
    returns (bool) {
        return _withdraw(
            name,
            amount
        );
    }

    /// POOL ADMIN CONTROLS
    function setup(
        string memory name,
        uint startTimestamp,
        uint duration,
        uint required,
        address[] memory whitelist
    ) public
    onlyIfExistingMatch(name)
    onlyAdminOf(name)
    monetize(settings.gas.setup)
    returns (bool) {
        uint now_ = block.timestamp;
        if (startTimestamp != 0) {
            require(
                startTimestamp >= now_,
                "Funding schedule starts in the past."
            );
        }

        if (duration != 0) {
            require(
                duration >= settings.minFundingDuration &&
                duration <= settings.maxFundingDuration,
                "Funding duration is out of bounds."
            );
        }

        require(
            required >= _converToWei(1), 
            "Insufficient required amount."
        );

        Pool storage pool = _pools[nameToIdentifier[name]];

        if (startTimestamp != 0) { pool.fundingSchedule.startTimestamp = startTimestamp; }
        else { pool.fundingSchedule.startTimestamp = now_; }
        
        if (duration != 0) { pool.fundingSchedule.duration = duration; }
        else { pool.fundingSchedule.duration = settings.minFundingDuration; }

        pool.fundingSchedule.endTimestamp = pool.fundingSchedule.startTimestamp + pool.fundingSchedule.duration;

        if (whitelist.length == 0) { pool.fundingSchedule.isWhitelisted = false; }

        pool.fundingSchedule.hasBeenSetup = true;

        emit PoolSetup(
            pool.name,
            pool.identifier,
            pool.fundingSchedule.startTimestamp,
            pool.fundingSchedule.endTimestamp,
            pool.fundingSchedule.duration,
            pool.fundingSchedule.required,
            whitelist
        );

        return true;
    }

    /// PUBLIC ACCESS
    function create(
        string memory name,
        string memory nameOfToken,
        string memory symbolOfToken,
        address[] memory managers,
        address[] memory admins
    ) public payable
    onlyIfNoExistingMatch(name)
    monetize(settings.gas.create)
    returns (
        uint,
        address
    ) {
        require(
            managers.length >= 1,
            "Must have at least one manager."
        );

        require(
            admins.length >= 1,
            "Must have at least one admin."
        );

        numberOfPools += 1;
        uint newIdentifier = numberOfPools;
        Pool storage pool = _pools[newIdentifier];
        pool.identifier = newIdentifier;
        pool.name = name;
        pool.creator = msg.sender;
        
        /// assign managers.
        for (
            uint i = 0;
            i < managers.length;
            i ++
        ) { pool.managers.add(managers[i]); }

        /// assign admins.
        for (
            uint i = 0;
            i < admins.length;
            i ++
        ) { pool.admins.add(admins[i]); }

        /// generate new token contract for this pool.
        /// mirai doesnt have control of these contracts.
        pool.token = new StandardToken(
            nameOfToken,
            symbolOfToken
        );

        pool.contractOfToken = address(pool.token);

        /// map name to identifier.
        nameToIdentifier[name] = newIdentifier;

        emit PoolCreated(
            pool.name,
            pool.identifier,
            pool.contractOfToken,
            managers,
            admins,
            pool.token.name(),
            pool.token.symbol()
        );

        return (
            newIdentifier,
            pool.contractOfToken
        );
    }

    function contribute(
        string memory name
    ) public payable
    onlyIfExistingMatch(name)
    onlyIfFundingScheduleHasBeenSetup(name)
    onlyAfterFundingScheduleStart(name)
    onlyBeforeFundingScheduleEnd(name)
    onlyIfFundingScheduleHasNotBeenCancelled(name)
    onlyIfFundingScheduleHasNotBeenCompleted(name)
    onlyWhitelist(name)
    monetize(settings.gas.contribute)
    returns (bool) {
        Pool storage pool = _pools[nameToIdentifier[name]];

        pool.token.mint(
            msg.sender,
            _amountToMint(
                msg.value,
                pool.token.totalSupply(),
                pool.vault.balance
            )
        );

        pool.vault.balance += msg.value;
    }

    function withdraw(
        string memory name,
        uint amount
    ) public
    onlyIfExistingMatch(name)
    onlyAfterFundingScheduleStart(name)
    returns (bool) {
        Pool storage pool = _pools[nameToIdentifier[name]];
        uint now_ = block.timestamp;
        bool scheduleHasStarted = now_ >= pool.fundingSchedule.startTimestamp;
        bool scheduleHasEnded = now_ >= pool.fundingSchedule.endTimestamp;
        bool scheduleIsOngoing = scheduleHasStarted == true && scheduleHasEnded == false;
        bool lockupDurationIsOver = now_ >= pool.fundingSchedule.startTimestamp + settings.lockupDuration;
        bool scheduleHasNotBeenCompleted = !pool.fundingSchedule.hasBeenCompleted;
        bool scheduleHasBeenCancelled = pool.fundingSchedule.hasBeenCancelled;
        
        if (
            scheduleIsOngoing &&
            lockupDurationIsOver &&
            scheduleHasNotBeenCompleted
        ) {
            return _withdrawAfterLockup(
                name,
                amount
            );
        }

        else if (
            scheduleHasEnded &&
            scheduleHasNotBeenCompleted
        ) {
            return _withdrawAfterFailedFundingSchedule(
                name,
                amount
            );
        }

        else if (
            scheduleHasStarted &&
            scheduleHasBeenCancelled
        ) {
            return _withdrawAfterCancellation(
                name,
                amount
            );
        }
    }
}