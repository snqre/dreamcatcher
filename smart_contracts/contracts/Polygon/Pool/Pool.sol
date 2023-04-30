// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(
        address _owner
    ) external view returns (uint256);
    function transfer(
        address _to, 
        uint256 _value
    ) external returns (bool success);
    function allowance(
        address _owner, 
        address _spender
    ) external view returns (uint256 remaining);
    function approve(
        address _spender, 
        uint256 _value
    ) external returns (bool success);
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) external returns (bool);
    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );
    event Approval(
        address indexed _owner, 
        address indexed _spender, 
        uint256 _value
    );
}

contract ERC20 is IERC20 {
    uint256 immutable infinite = type(uint256).max;
    struct My {
        address admin;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
    }
    My private my;
    mapping(address => uint256) private balance;
    mapping(address => uint256) private allowed;

    modifier admin() {
        require(
            my.admin == msg.sender ||
            address(this) == msg.sender
        );
        _;
    }

    constructor(
        address _admin,
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        require(
            _initialSupply > 1 &&
            _initialSupply < infinite &&
            _admin != address(0) &&
            _admin != address(this)
        );

        my.admin = _admin;
        my.name = _name;
        my.symbol = _symbol;
        my.decimals = 18;
        
        mint(
            my.admin, 
            _initialSupply
        );
    }

    function name() public view returns (string memory) {return my.name;}
    function symbol() public view returns (string memory) {return my.symbol;}
    function decimals() public view returns (uint8) {return my.decimals;}
    function totalSupply() public view returns (uint256) {return my.totalSupply;}
    function balanceOf(address _owner) public view returns (uint256) {return balance[_owner];}

    function allowance(address _owner, address _spender) public view returns (uint256) {
        uint256 allowed[_owner][_spender];
    }
    
    function mint(
        address _to,
        uint256 _value
    ) public admin returns (bool) {
        address _from = address(0);
        require(
            _value >= 0 &&
            _to != address(0)
        );

        my.totalSupply += _value;
        balance[_to] += _value;

        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }

    function burn(
        address _from,
        uint256 _value
    ) public admin returns (bool) {
        address _to = address(0);
        require(
            _value >= 0 &&
            _value <= balance[_from] &&
            _from != address(0)
        );

        my.totalSupply -= _value;
        balance[_from] -= _value;

        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _from = msg.sender;
        require(
            _from != address(0) &&
            _to != address(0) &&
            _value <= balance[_from] &&
            _value >= 0
        );

        balance[_from] -= _value;
        balance[_to] += _value;
        
        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _spender = msg.sender;
        uint256 _allwnc = allowed[_from][_spender];
        require(
            _allwnc != infinite &&
            _allwnc >= _value &&
            _from != address(0) &&
            _to != address(0) &&
            _value <= balance[_from] &&
            _value >= 0
        );

        allowed[_from][_spender] -= _value;
        balance[_from] -= _value;
        balance[_to] += _value;

        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool) {
        address _owner = msg.sender;
        require(
            _owner != address(0) &&
            _spender != address(0)
        );

        allowed[_owner][_spender] = _value;

        emit Approval(
            _owner,
            _spender,
            _value
        );

        return true;
    }
}

contract Pool {
    bool whitelisted;   // only whitelisted addresses can deposit within this pool
    address creator;    // creator of the pool
    address manager;    // manager of the pool
    string name;        // name of the pool
    uint256 balance;    // balance in matic
    ERC20 nativeToken;  // specially generated ERC2O token for this pool
    mapping(address=>bool) private whitelist;
    mapping(address=>uint256) private treasury;

    modifier onlyWhitelist () {
        require(
            whitelisted &&
            whitelist[msg.sender]
        );
        _;
    }

    constructor(
        address _manager,
        string memory _name,
        string memory _tknName,
        string memory _tknSymbol,
        uint256 _tknSupply
    ) {
        creator = msg.sender;
        manager = _manager;
        name = _name;

        address _admin = address(this);
        nativeToken = new ERC20(
            _admin,
            _tknName,
            _tknSymbol,
            _tknSupply
        );
    }

    function contribute() public onlyWhitelist returns (bool) {
        uint256 _value = msg.value;
        uint256 _balance = balance;
        uint256 _supply = nativeToken.totalSupply();
        uint256 _amountOfTokensToMint = (_value * _balance) / _supply;
        require(
            _value > 0 &&
            _balance > 0 &&
            _supply > 0 &&
            _amountOfTokensToMint <= nativeToken.balanceOf(address(this))
        );
        nativeToken.transfer(msg.sender, _amountOfTokensToMint);
        return true;
    }

    

}