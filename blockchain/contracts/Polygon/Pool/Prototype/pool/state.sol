// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/pool/token.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract State {
    struct Lock {bool isUnlocked;} Lock private lock;
    struct Tracker {uint256 numberOfPools;} Tracker private tracker;
    struct FundingSchedule {
        uint256 start;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool success;
    }

    struct Pool {
        uint256 reference;
        uint256 balance;
        Token token;
        FundingSchedule fundingSchedule;
    }

    struct Account {
        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;
        uint256[] contribution;
    }

    mapping(address => Account) private accounts;
    mapping(uint256 => Pool) private pools;

    constructor() {}

    function createNewPool(
        string memory _name,
        string memory _description,
        address[] _managers,
        string _nameToken,
        string _symbolToken,
        uint256 _duration,
        uint256 _required,
        bool _whitelisted
    ) public payable returns (bool) {
        require(lock.isUnlocked);
        /** moderation */
        require(_duration >= 1 days);
        require(_required >= 0);

        lock.isUnlocked = false;
        
        Account _caller = accounts[msg.sender];
        /** assign new reference */
        tracker.numberOfPools ++;
        uint256 _reference = tracker.numberOfPools;
        
        /** create erc20 token contract */
        Token _token = new Token(_nameToken, _symbolToken);

        /** create funding schedule for launch */
        _now = block.timestamp;
        FundingSchedule _fundingSchedule = FundingSchedule({
            start: _now,
            end: _now + _duration,
            required: _required,
            whitelisted: _whitelisted,
            success: false
        });

        /** assign ownership of pool to creator address */
        pools[_reference] = Pool({
            reference: _reference,
            balance: msg.value,
            token: _token,
            fundingSchedule: _fundingSchedule
        });

        lock.isUnlocked = true;
        return true;
    }

    function contribute(uint256 _reference) public payable returns (bool) {
        Account _caller = accounts[msg.sender];
        Pool _pool = pools[_reference];
        
        if (_pool.fundingSchedule.whitelisted) {require(_caller.isOnWhitelist[_reference]);}
        /**
        * _v: value
        * _s: supply
        * _b: balance
        * _m: amount to mint
         */
        uint256 _v = msg.value;
        uint256 _s = _pool.token.totalSupply() / 10**18;/** */
        uint256 _b = _pool.balance;
        uint256 _m = Lib._how_much_to_mint(_v, _s, _b);//** */

        require(_v > 0);
        require(_s > 0);
        require(_b > 0);
        
        require(block.timestamp <= _pool.fundingSchedule.end);

        _pool.token.mint(msg.sender, _m);

        return true;
        
    }

}