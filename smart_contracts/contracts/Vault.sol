// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract State {
    address internal nativeTokenContract;
    address internal nativeAdminContract;    // governor
    address internal quickSwapContract;
    /** map */
    mapping(string => address)   internal map;

    /** permissions */
    mapping(address => bool)     internal admin;

    /** accounting */
    mapping(string => address)   internal holdingsContract;
    mapping(string => uint256)   internal holdings;
    mapping(string => uint256)   internal ask;
    mapping(string => uint256)   internal bid;
    mapping(string => uint256)   internal available;
    mapping(string => bool)      internal swappable;
}

interface IAuthenticator {
    
    function grantPermissionAdmin(address _owner) external returns (bool);
    function revokePermissionAdmin(address _owner) external returns (bool);
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function decimals() external view returns (uint8);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 _valueIn,
        uint256 _valueOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) external returns (uint256[] memory _values);
}

interface IVault {

    function swapLocalForMATIC(string _symbol) payable external returns (bool);
    function swapLocalForToken(string _symbol, uint256 _value) payable external returns (bool);
    function depositERC20(address _contract, uint256 _value) external returns (bool);
    function withdrawERC20(address _contract, address _to, uint256 _value) external returns (bool);
    function depositMATIC(uint256 _value) payable external returns (bool);
    function withdrawMATIC(address _to, uint256 _value) external returns (bool);
    function fetchHoldings(string _symbol) external view returns (uint256);
}

contract Vault is State {

    /**
    Pre Seed Funding    $0.035
    Seed Funding        $0.050
    Series A            $0.250
    Series B            $0.500
    ICO                 $1.000
     */
    constructor(address _dev) {
        admin[msg.sender]    = true;
        admin[_dev]          = true;

        map["UNISWAP_V2_ROUTER"] = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
        map["NATIVE_TOKEN"] = address(0);
        map["NATIVE_ADMIN"] = address(0);
        holdingsContract["WETH"] = 0x7ceb23fd6bc0add59e62ac25578270cff1b9f619;
    }
    
    function swapLocalForMATIC(string _symbol) payable external returns (bool) {
        /** we give x token for x MATIC */
        address _from = address(this);
        address _to = msg.sender;
        uint256 _ask = ask[_symbol];
        uint256 _swapValue = msg.value / _ask;
        address _contract = holdingsContract[_symbol];
        uint256 _holdings = holdings[_symbol];
        uint256 _available = available[_symbol];
        bool _swappable = swappable[_symbol];
        IERC20 _token = IERC20(_contract);
        require(
            _swappable &&
            msg.value > 0 &&
            _swapValue <= _token.balanceOf(_from) &&
            _swapValue <= _available &&
            _ask >= 0 &&
            _contract != address(0) &&
            _contract != 0
        );
        /** recieve MATIC */
        holdings["MATIC"] += msg.value;
        /** send Tokens */
        available[_symbol] -= _swapValue;
        holdings[_symbol] -= _swapValue;
        _token.transfer(_to, _swapValue);
        return true;
    }

    function swapLocalForToken(string _symbol, uint256 _value) payable external returns (bool) {
        /** we give x MATIC for x token */
        address _from = address(this);
        address _to = msg.sender;
        uint256 _bid = bid[_symbol];
        uint256 _swapValue = _value * _bid;
        address _contract = holdingsContract[_symbol];
        uint256 _holdings = holdings[_symbol];
        uint256 _holdingsMATIC = holdings["MATIC"];
        uint256 _available = available[_symbol];
        bool _swappable = swappable[_symbol];
        IERC20 _token = IERC20(_contract);
        require(
            _swappable &&
            msg.value > 0 &&
            _swapValue <= _holdingsMATIC &&
            _swapValue <= _available &&
            _bid > 0 &&
            _contract != address(0) &&
            _contract != 0 &&
        );
        /** recieve Tokens */
        _token.transferFrom(_to, _from, _value);
        holdings[_symbol] += _value
        /** send MATIC */
        _from.transfer(_swapValue);
        available[_symbol] -= _swapValue;
        holdings["MATIC"] -= msg.value;
        return true;
    }

    function swapOnUniswap(
        address _contractIn,    // address of token in
        address _contractOut,   // address of token out
        uint256 _valueIn,       // amount of token in
        uint256 _valueOutMin   // min amount of token out
    ) external returns (bool) {
        require(
            admin[msg.sender]
        );
        _to = address(this);
        IERC20 _tokenIn = IERC20(_contractIn);
        IERC20 _tokenOut = IERC20(_contractOut);

        _tokenIn.transferFrom(msg.sender, address(this), _valueIn);
        _tokenIn.approve(map["UNISWAP_V2_ROUTER"], _valueIn);
        
        address[] memory _path;
        _path = new address[](3);
        _path[0] = _contractIn;
        _path[1] = holdingsContract["WETH"];
        _path[2] = _contractOut;

        IUniswapV2Router(map["UNISWAP_V2_ROUTER"]).swapExactTokensForTokens(
            _valueIn,
            _valueOutMin,
            _path,
            _to,
            block.timestamp
        );
    }

    function depositERC20(address _contract, uint256 _value) payable external returns (bool) {
        IERC20 _token = IERC20(_contract);
        address _from = msg.sender;
        address _to = address(this);
        require(
            _value <= _token.balanceOf(_from) &&
            _to != address(0) &&
            _from != address(0)
        );
        bool _success = _token.transferFrom(_from, _to, _value * 10**_token.decimals());
        cont[_token.symbol()] = _contract;
        if (_success == true) {holdings[_token.symbol()] += _value;}
        return _success;
    }

    function withdrawERC20(address _contract, address _to, uint256 _value) payable external returns (bool) {
        IERC20 _token = IERC20(_contract);
        address _from = address(this);
        require(
            admin[msg.sender] &&
            _value <= _token.balanceOf(_from) &&
            _to != address(0) &&
            _from != address(0)
        );
        bool _success = _token.transfer(_to, _value * 10**_token.decimals());
        if (_success == true) {holdings[_token.symbol()] -= _value;}
        return _success;
    }

    function depositMATIC(uint256 _value) payable external returns (bool) {
        holdings["MATIC"] += msg.value;
        return true;
    }

    function() payable external returns (bool) {
        holdings["MATIC"] += msg.value;
        return true;
    }

    function withdrawMATIC(address _to, uint256 _value) payable external returns (bool) {
        require(
            admin[msg.sender] &&
            _value <= holdings["MATIC"]
        );
        _to.transfer(_value);
        holdings["MATIC"] -= msg.value;
        return true;
    }

    updateHoldingsContract(string _symbol, address _newContract) external returns (bool) {
        require(
            admin[msg.sender]
        );
        holdingsContract[_symbol] = _newContract;
        return true;
    }

    updateAsk(string _symbol, uint256 _ask) external returns (bool) {
        require(
            admin[msg.sender] &&
            _ask >= 0
        );
        ask[_symbol] = _ask;
        return true;
    }

    updateBid(string _symbol, uint256 _bid) external returns (bool) {
        require(
            admin[msg.sender] &&
            _bid >= 0
        );
        bid[_symbol] = _bid;
        return true;
    }

    increaseAvailable(string _symbol, uint256 _increase) external returns (bool) {
        require(
            admin[msg.sender] &&
            _increase >= 0
        );
        available[_symbol] += _increase;
        return true;
    }

    decreaseAvailable(string _symbol, uint256 _decrease) external returns (bool) {
        require(
            admin[msg.sender] &&
            _decrease >= 0 &&
            available[_symbol] - _decrease >= 0
        );
        available[_symbol] -= _decrease;
        return true;
    }

    updateAvailable(string _symbol, uint256 _newValue) external returns (bool) {
        require(
            admin[msg.sender] &&
            _newValue >= 0
        );
        available[_symbol] = _newValue;
        return true;
    }

    updateSwappable(string _symbol, bool _swappable) external returns (bool) {
        require(
            admin[msg.sender]
        );
        swappable[_symbol] = _swappable;
        return true;
    }

    fetchHoldingsContract(string _symbol) external view returns (address) {return holdingsContract[_symbol];}
    fetchHoldings(string _symbol) external view returns (uint256) {return holdings[_symbol];}
    fetchAsk(string _symbol) external view returns (uint256) {return ask[_symbol];}
    fetchBid(string _symbol) external view returns (uint256) {return bid[_symbol];}
    fetchAvailable(string _symbol) external view returns (uint256) {return available[_symbol];}
    fetchSwappable(string _symbol) external view returns (uint256) {return swappable[_symbol];}

    function update(
        address _nativeTokenContract, 
        address _nativeAdminContract) external returns (bool) {
        address _from = msg.sender;
        require(
            admin[_from] &&
            _nativeTokenContract != address(0) &&
            _nativeAdminContract != address(0)
        );
        /** revoke admin privilate of current contract */
        admin[
            map["NATIVE_TOKEN"]
        ] = false;
        /** update contract */
        map["NATIVE_TOKEN"] = _nativeTokenContract;
        /** grant admin privilage to new contract */
        admin[
            map["NATIVE_TOKEN"]
        ] = true;

        /** revoke admin privilate of current contract */
        admin[
            map["NATIVE_ADMIN"]
        ] = false;
        /** update contract */
        map["NATIVE_ADMIN"] = _nativeAdminContract;
        /** grant admin privilage to new contract */
        admin[
            map["NATIVE_ADMIN"]
        ] = true;

        return true;
    }

    function fetch() external returns (address, address) {
        address _from = msg.sender;
        require(
            admin[_from]
        );
        return (
            map["NATIVE_TOKEN"],
            map["NATIVE_ADMIN"]
        );
    }
}