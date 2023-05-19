// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/Pools/Utils.sol";

contract SingleState is Ownable, Address, ReentrancyGuard {
    struct Tracker {uint256 numberOfPools;} Tracker public tracker;
    struct InitialFundingSchedule {
        uint256 startTimestamp;
        uint256 durationSeconds;
        uint256 requiredInMatic;
        bool isWhitelisted;
        bool success;
    }

    struct Pool {
        uint256 id;
        string name;
        uint256 balanceInMatic;
        InitialFundingSchedule initialFundingSchedule;
        SimpleToken simpleToken;
    }

    mapping(uint256 => Pool) public pools;

    /** roles */
    struct Account {
        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;
    }

    mapping(address => Account) public accounts;

    struct Settings {
        uint256 priceToCreateNewPool;
        uint256 feeToContribute;
        uint256 feeToWithdraw;
        address dreamToken;
        address safe;
    }
    
    Settings public settings;

    constructor() Ownable() {}

    function createNewPool(
        string memory name,
        address[] managers,
        string memory nameToken,
        string memory symbolToken,
        uint256 durationSeconds,
        uint256 requiredInMatic,
        bool isWhitelisted
    ) public payable nonReentrant returns (bool) {
        require(durationSeconds >= 604800 seconds);
        require(requiredInMatic >= 0);
        /** if there is a cost then execute */
        if (settings.priceToCreateNewPool > 0) {
            IERC20(settings.dreamToken).transferFrom(
                msg.sender,
                settings.safe,
                settings.priceToCreateNewPool
            );
        }
        /** generate new id and deploy new token contract */
        require(tracker.numberOfPools < type(uint256).max);
        tracker.numberOfPools += 1;
        uint256 id = tracker.numberOfPools;
        SimpleToken simpleToken = new SimpleToken(nameToken, symbolToken);
        uint256 now_ = block.timestamp;
        /** generate initial funding schedule */
        InitialFundingSchedule memory initialFundingSchedule = InitialFundingSchedule({
            startTimestamp: now_,
            durationSeconds: durationSeconds,
            requiredInMatic: requiredInMatic,
            isWhitelisted: isWhitelisted,
            success: false
        });
        /** generate new pool */
        pools[id] = Pool({
            id: id,
            name: name,
            balanceInMatic: msg.value,
            initialFundingSchedule: initialFundingSchedule,
            simpleToken: simpleToken
        });
        /** set managers and give whitelist permission */
        for (uint256 i = 0; i < managers.length; i++) {
            Account memory manager = accounts[managers[i]];
            manager.isManager[id] = true;
            manager.isOnWhitelist[id] = true;
            accounts[managers[i]] = manager;
        }

        return true;
    }

    function contribute(uint256 id) public payable nonReentrant returns (bool) {
        uint256 value = msg.value;
        require(value > 0);
        /** get pool and caller meta data */
        Account memory caller = accounts[msg.sender];
        Pool memory pool = pools[id];
        /** check if pool is whitelisted and if caller is whitelisted */
        if (pool.initialFundingSchedule.isWhitelisted) {
            require(caller.isOnWhitelist[id]);
        }
        /** required for math */
        uint256 supply = pool.simpleToken.totalSupply();
        uint256 balance = pool.balanceInMatic;
        uint256 amountToMint = Utils.valueToMint(value, supply, balance);
        
        require(amountToMint > 0);

        require(block.timestamp <= pool.initialFundingSchedule.startTimestamp + pool.initialFundingSchedule.durationSeconds);

        if (settings.feeToContribute > 0) {
            uint256 fee = (amountToMint * settings.feeToContribute) / 10000;
            amountToMint -= fee;
            /** mint fee of tokens to safe */
            pool.simpleToken.mint(settings.safe, fee);
        }
        /** update */
        pool.balanceInMatic += value;
        pool.simpleToken.mint(msg.sender, amountToMint);
        pools[id] = pool;
        accounts[msg.sender] = caller;

        return true;
    }

    function withdraw(uint256 id, uint256 amount) public nonReentrant returns (bool) {
        require(value > 0);
        Pool memory pool = pools[id];

        uint256 supply = pool.simpleToken.totalSupply();
        uint256 balance = pool.balanceInMatic;
        uint256 valueToSend = Utils.burnToValue(amount, supply, balance);
        
        require(pool.balanceInMatic >= valueToSend);
        /** fees */
        if (settings.feeToWithdraw > 0) {
            uint256 fee = (amount * settings.feeToWithdraw) / 10000;
            valueToSend -= fee;
            sendValue(settings.safe, fee);
        }
        /** burn and send value */
        pool.simpleToken.burn(msg.sender, amount);
        sendValue(msg.sender, valueToSend);
        pool.balanceInMatic -= valueToSend;
        
        return true;
    }

}