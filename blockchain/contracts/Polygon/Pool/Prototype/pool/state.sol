// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
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

    address nativeToken;

    struct PriceTo {
        uint256 createNewPool;
    }

    PriceTo priceTo;

    struct FeeTo {
        uint256 contribute;
        uint256 withdraw;
    }

    FeeTo feeTo;

    constructor() {}

    function createNewPool(
        string memory _name,
        string memory _description,
        address[] _managers,
        string memory _nameOfToken,
        string memory _symbolOfToken,
        uint256 _duration,
        uint256 _required,
        bool _whitelisted
    ) public payable returns (bool) {
        require(_duration >= 1 days, "funding phase must last more than 24 hours");
        require(_required >= 0, "_required < 0");
        
        if (priceTo.createNewPool > 0) {
            IERC20 _nativeToken = IERC20(_nativeToken);
            _nativeToken.transferFrom(
                msg.sender,
                address(this),
                Utils.convertToWei(priceTo.createNewPool);
            );
        }

        tracker.numberOfPools += 1;
        uint256 _reference = tracker.numberOfPools;

        Token _token = new Token(_nameOfToken, _symbolOfToken);

        _now = block.timestamp;
        FundingSchedule _fundingSchedule = FundingSchedule({
            start: _now,
            end: _now + _duration,
            required: _required,
            whitelisted: _whitelisted,
            success: false
        });

        pools[_reference] = Pool({
            reference: _reference,
            balance: msg.value,
            token: _token,
            fundingSchedule: _fundingSchedule
        });

        return true;
    }

    function contribute(uint256 _reference) public payable returns (bool) {
        require(msg.value > 0, "msg.value <= 0");
        
        Account memory _caller = accounts[msg.sender];
        Pool memory _pool = pools[_reference];

        if (_pool.fundingSchedule.whitelisted) {
            require(_caller.isOnWhitelist[_reference], "this pool is whitelisted and you are not on it");
        }

        uint256 _v = msg.value;
        uint256 _s = Utils.convertToInt(_pool.token.totalSupply());
        uint256 _b = _pool.balance;
        uint256 _m = Utils.howMuchToMint(_v, _s, _b);
        
        require(_v > 0, "_v <= 0");
        require(_s > 0, "_s <= 0");
        require(_b > 0, "_b <= 0");

        require(block.timestamp <= _pool.fundingSchedule.end, "the contribution period for this pool has expired");

        _pool.balance += msg.value;
        
        _pool.token.mint(_m);
        _pool.token.transfer(msg.sender, _m);

        pools[_reference] = _pool;
        accounts[msg.sender] = _caller;

        return true;
    }

    function withdraw(uint256 _reference, uint256 _value) public returns (bool) {
        require(_value > 0, "_value <= 0");

        Account memory _caller = accounts[msg.sender];
        Pool memory _pool = pools[_reference];

        uint256 _a = _value;
        uint256 _s = _pool.token.totalSupply();
        uint256 _b = _pool.balance;
        uint256 _v = Utils.howMuchToSend(_a, _s, _b);

        require(_pool.balance >= _v, "insufficient balance to send to withdrawer");

        _pool.token.transferFrom(msg.sender, address(this), _value);
        _pool.token.burn(_value);
        
        _pool.balance -= _v;

        address payable _to = payable(msg.sender);
        _to.transfer(_v);

        return true;
    }
}