// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/Pools/Utils.sol";

interface IStandAlone {
    event PoolCreated(
        address indexed creator,
        string name,
        addres[] managers,
        string memory nameToken,
        string memory symbolToken,
        uint256 durationSeconds,
        uint256 requiredInMatic,
        bool isWhitelist
    );

    event Contribution(
        address indexed contributor,
        uint256 contribution,
        uint256 amountMinted
    );

    event Withdrawal(
        address indexed withdrawer,
        uint256 amountBurnt,
        uint256 withdraw
    );
}

/** stand alone single contract for one pool no connection to dreamcatcher no benefits no ongoing streaming fees */
contract StandAlone is Ownable, Address, ReentrancyGuard {
    struct InitialFundingSchedule {
        uint256 startTimestamp;
        uint256 durationSeconds;
        uint256 requiredInMatic;
        bool isWhitelisted;
        bool success;
    }
    
    struct Pool {
        string name;
        address[] managers;
        InitialFundingSchedule initialFundingSchedule;
        SimpleToken simpleToken;
    }

    Pool pool;

    struct Account {
        bool isAdmin;
        bool isCreator;
        bool isManager;
        bool isOnWhitelist;
    }

    mapping(address => Account) public accounts;
    /** proxy compatible */
    constructor(args) Ownable() payable {
        (
            string memory name,
            address[] managers,
            string memory nameToken,
            string memory symbolToken,
            uint256 durationSeconds,
            uint256 requiredInMatic,
            bool isWhitelisted
        ) = abi.decode(
            args,
            (
                string,
                address[],
                string,
                string,
                uint256,
                uint256,
                bool
            )
        );

        require(
            durationSeconds >= 604800 seconds,
            "SingleState::createNewPool: durationSeconds < 604800 seconds"
        );

        require(
            requiredInMatic >= 0,
            "SingleState::createNewPool: requiredInMatic < 0"
        );

        SimpleToken simpleToken = new SimpleToken(nameToken, symbolToken);
        uint256 now_ = block.timestamp;
        /** generate intiial funding schedule */
        InitialFundingSchedule memory initialFundingSchedule = InitialFundingSchedule({
            startTimestamp: now_,
            durationSeconds: durationSeconds,
            requiredInMatic: requiredInMatic,
            isWhitelisted: isWhitelisted,
            success: false
        });
        /** generate new pool */
        pool = Pool({
            name: name,
            managers: managers,
            initialFundingSchedule: initialFundingSchedule,
            SimpleToken: simpleToken
        });
        /** set managers and give whitelist permission */
        for (uint256 i = 0; i < managers.length; i++) {
            Account memory manager = accounts[managers[i]];
            manager.isManager = true;
            manager.isOnWhitelist = true;
            accounts[managers[i]] = manager;
        }

        emit PoolCreated(
            msg.sender,
            name,
            managers,
            nameToken,
            symbolToken,
            durationSeconds,
            requiredInMatic,
            isWhitelist
        );

        return true;

    }


}