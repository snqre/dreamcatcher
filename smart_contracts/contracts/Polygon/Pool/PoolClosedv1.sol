// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract Pool is IERC20 {
    // =.=.= utils
    uint256 infinite = type(uint256).max;

    // =.=.= token
    struct Token {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 maxSupply;
    }

    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private allowed;
    Token token;

    // =.=.= pool
    IERC20[] public tokens;
    AggregatorV3Interface public priceAggregator;

    // =.=.= permission
    mapping(address => bool) private isAdmin;
    mapping(address => bool) private isManager;

    modifier admin() {
        require(isAdmin[msg.sender]);
        _;
    }

    modifier manager() {
        require(isManager[msg.sender]);
        _;
    }

    constructor(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _maxSupply
    ) {
        require(
            _decimals >= 0 &&
            _decimals <= 18 &&
            _maxSupply >= 1 &&
            _maxSupply <= infinite
        );

        token.name = _name;
        token.symbol = _symbol;
        token.decimals = _decimals;
        token.totalSupply = 0;
        token.maxSupply = _maxSupply;

        isManager[msg.sender] = true;
        isAdmin[msg.sender] = true;
    }

    function transfer_(address _from, address _to, uint256 _value) private {
        require(
            _from != address(0) &&
            _to != address(0) &&
            balance[_from] >= _value &&
            balance[_from] >= 0 &&
            _value >= 0
        );

        balance[_from] -= _value;
        balance[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function mint_(address _to, uint256 _value) private {
        address _from = address(0);
        require(
            _value >= 0 &&
            _value + token.totalSupply <= token.maxSupply &&
            _to != address(0)
        );

        token.totalSupply += _value;
        balance[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function burn_(address _from, uint256 _value) private {
        address _to = address(0);
        require(
            _value >= 0 &&
            _value <= balance[_from]
        );

        token.totalSupply -= _value;
        balance[_from] -= _value;

        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        address _from = msg.sender;
        transfer_(_from, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        address _spender = msg.sender;
        uint256 _allwnc = allowed[_from][_spender];
        require(
            _allwnc != infinite &&
            _allwnc >= _value
        );

        allowed[_from][_spender] -= _value;
        transfer_(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        address _owner = msg.sender;
        require(
            _owner != address(0) &&
            _spender != address(0) &&
            _value >= 0
        );

        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function name() public view returns (string memory) {return token.name;}
    function symbol() public view returns (string memory) {return token.symbol;}
    function decimals() public view returns (uint8) {return token.decimals;}
    function maxSupply() public view returns (uint256) {return token.maxSupply;}
    function balanceOf(address _owner) public view returns (uint256) {return balance[_owner];}
    function allowance(address _owner, address _spender) public view returns (uint256) {return allowed[_owner][_spender];}

    // =.=.= POOL
    function addToken(IERC20 _token) public manager {
        tokens.push(_token);
    }

    function setPriceAggregator(address _priceAggregator) public manager {
        priceAggregator = AggregatorV3Interface(_priceAggregator);
    }

    function getBalance() public view returns (uint256) {
        uint256 _sumValueInMatic = 0;
        for (uint i = 0; i < tokens.length; i++) {
            uint256 _tokenBalance = tokens[i].balanceOf(address(this));
            uint256 _exchangeRate = getPrice(tokens[i]);

            uint256 _tokenValueInMatic = (_tokenBalance * _exchangeRate) / 10**18;
            _sumValueInMatic += _tokenValueInMatic;
        }
        
        return _sumValueInMatic;
    }

    function getPrice(IERC20 _token) public view returns (uint256) {
        address _tokenAddress = address(_token);
        uint256 _tokenDecimals = _token.decimals();

        (, int256 price, , ,) = priceAggregator.latestRoundData();

        uint256 _exchangeRate = uint256(price) * 10**(18 - _tokenDecimals);

        return _exchangeRate;
    }

    function contribute() public returns (bool) {
        address _buyers = msg.sender;
        address _seller = address(this);
        uint256 _value = msg.value;
        uint256 _balance = getBalance();
        uint256 _supply = token.totalSupply;
        require(
            _value > 0 &&
            _balance > 0 &&
            _supply > 0
        );
        uint256 _amountOfTokensToMint = (_value * _supply) / _balance;
        mint_(_buyers, _amountOfTokensToMint);
        return true;
    }
}