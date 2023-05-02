pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/Pool/Prototype/ClosedPool/State.sol";
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

contract Pool {
    string name;
    State immutable state;
    Token token;
    mapping(address => bool) private isAdmin;
    mapping(address => bool) private isManager;
    modifier admin() {
        require(isAdmin[msg.sender], "Pool: msg.sender != admin");
        _;
    }

    modifier manager() {
        require(isManager[msg.sender], "Pool: msg.sender != manager");
        _;
    }

    modifier any() {
        require(
            isAdmin[msg.sender] ||
            isManager[msg.sender],
            "Pool: msg.sender != any"
        );
        _;
    }

    // TODO -- When constructor init (State: msg.sender != admin)?
    constructor(
        string memory _name,
        address _manager,
        string memory _tknName,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _duration,
        uint256 _required
    ) {
        name = _name;
        uint256 _now = block.timestamp;
        address _admin = address(this);
        require(
            _initialSupply >= 1 &&
            _duration >= 1 weeks &&
            _required >= 1
        );

        state = new State(
            _admin
        );

        state.setInitialFunding(_now, _duration, _required);

        token = new Token(
            _admin,
            _tknName,
            _symbol
        );
    }

    function setToggles(bool _extensions, bool _whitelist) public manager returns (bool) {
        state.setToggles(_extensions, _whitelist);
        return true;
    }
    
    function setWhitelist(address _account, bool _state) public manager returns (bool) {
        state.setWhitelist(_account, _state);
        return true;
    }

    function contribute() public payable returns (bool) {
        uint256 _amount = msg.value;
        uint256 _supply = token.totalSupply();
        uint256 _balance = address(this).balance;
        uint256 _amountToMint = (_amount * _supply) / _balance;
        address _to = msg.sender;
        (
            uint256 _start,
            uint256 _duration,
            uint256 _required
        ) = state.getInitialFunding();
        uint256 _end = _start + _duration;
        uint256 _now = block.timestamp;
        require(
            _amount  >= 0 &&             // need >= 0 deposit
            _supply  >= 1 &&             // need more than 1 token
            _balance >= 1 &&             // need more than 1 matic
            _balance <= _required &&     // check if the required amount is met
            _end     >= _now             // check funding is still ongoing
        );

        // mint tokens for contributor
        token.mint(_to, _amountToMint);
        state.setContribution(_to, _amount);
        return true;
    }
}