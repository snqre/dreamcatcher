// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function approve(address _spender, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract ERC20 is IERC20 {
    struct My {
        address admin;
        string name;
        string symbol;
        uint8 decimals;
        uint256 mintable;
        uint256 totalSupply;
        uint256 maxSupply;
    }
    My private my;
    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private allowed;
    modifier onlyAdmin() {
        require(my.admin == msg.sender || address(this) == msg.sender);
    }

    constructor(
        address _admin,
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _maxSupply
    ) {
        require(
            _decimals >= 0 &&
                _decimals <= 18 &&
                _admin != address(0) &&
                _maxSupply >= 1
        );
        my.admin = _admin;
        my.name = _name;
        my.symbol = _symbol;
        my.decimals = _decimals;
        my.maxSupply = _maxSupply;
        my.mintable = _maxSupply;
        my.totalSupply = 0;
    }

    function transfer_(
        address _from,
        address _to,
        uint256 _value
    ) private {
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
        require(_value >= 0 && _value <= my.mintable && _to != address(0));
        my.mintable -= _value;
        my.totalSupply += _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function burn_(address _from, uint256 _value) private {
        address _to = address(0);
        require(_value >= 0 && _value <= balance[_from]);
        my.totalSupply -= _value;
        balance[_from] -= _value;
        emit Transfer(_from, _to, _value);
    }

    function mint(address _to, uint256 _value) public onlyAdmin returns (bool) {
        _mint(_to, _value);
    }

    function burn(address _from, uint256 _value)
        public
        onlyAdmin
        returns (bool)
    {
        _mint(_to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        address _from = msg.sender;
        transfer_(_from, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _spender = msg.sender;
        uint256 _allwnc = allowed[_from][_spender];
        require(_allwnc != type(uint256).max && _allwnc >= _value);
        allowed[_from][_spender] -= _value;
        transfer_(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        address _owner = msg.sender;
        require(_owner != address(0) && _spender != address(0) && _value >= 0);
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function name() public view returns (string memory) {
        return my.name;
    }

    function symbol() public view returns (string memory) {
        return my.symbol;
    }

    function decimals() public view returns (uint8) {
        return my.decimals;
    }

    function maxSupply() public view returns (uint256) {
        return my.maxSupply;
    }

    function mintable() public view returns (uint256) {
        return my.mintable;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balance[_owner];
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}
