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

/** unlimited supply token for open ended fund */
contract ERC20Uncapped {
    /** structure token */
    struct Token {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
    }
    /** basic accounting */
    mapping(address=>uint256) private balance;
    mapping(address=>uint256) private allowed;
    address admin;
    /** events */
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

    modifier onlyAdmin() {
        require(
            admin == msg.sender
        );
        _;
    }

    /** init */
    constructor(
        address _admin,
        string _name,
        string _symbol,
        uint8 _decimals
    ) {
        require(
            _decimals <= 18
        );
        /** init meta data */
        token.name = _name;
        token.symbol = _symbol;
        token.decimals = _decimals;
    }

    function mint_(
        address _to,
        uint256 _value
    ) public onlyAdmin returns (bool) {
        address _from = address(0);
        require(
            _value >= 0 &&
            _to != address(0)
        );

        token.totalSupply += _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn_(
        address _from,
        uint256 _value
    ) public onlyAdmin {
        address _to = address(0);
        require(
            _value >= 0 &&
            _value <= balance[_from] &&
            _from != address(0)
        );

        token.totalSupply -= _value;
        balance[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function transfer_(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0) &&
            _to != address(0) &&
            _value <= balance[_from] &&
            _value >= 0
        );

        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _from = msg.sender;
        transfer_(
            _from,
            _to,
            _value
        );
        return true;
    }
    /** public transfer from */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _spender
        uint256 _allwnc = allowed[_from][_spender]
        require(
            _allwnc != type(uint256).max &&
            _allwnc >= _value
        );

        allowed[_from][_spender] -= _value;
        transfer_(
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
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function name() public view returns (string memory) {return token.name;}
    function symbol() public view returns (string memory) {return token.symbol;}
    function decimals() public view returns (uint8) {return token.decimals;}
    function totalSupply() public view returns (uint256) {return token.totalSupply;}
    function balanceOf(
        address _owner
    ) public view returns (uint256) {return balance[_owner];}
    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {return allowed[_owner][_spender];}
}

/** limited supply token for closed ended fund */
contract ERC20Capped {
    /** structure token */
    struct Token {
        string name;
        string symbol;
        uint8 decimals;
        uint256 mintable;
        uint256 maxSupply;
        uint256 totalSupply;
    }
    /** basic accounting */
    mapping(address=>uint256) private balance;
    mapping(address=>uint256) private allowed;
    address admin;
    /** onchain analytics */
    /** events */
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

    /** init */
    constructor(
        address  _admin,
        string   _name,
        string   _symbol,
        uint8    _decimals,
        uint256  _mintable,
        uint256  _initialSupply
    ) {
        require(
            _decimals <= 18
        );
        /** init meta data */
        token.name = _name;
        token.symbol = _symbol;
        token.decimals = _decimals;
        token.mintable = _mintable * 10**_decimals;
        token.maxSupply = _mintable * 10**_decimals;
        /** assign permission */
        admin = _admin;
        /** main: mint initial to admin contract or vault */
        mint_(
            admin,
            _mintable * 10**_decimals
        );
    }
    /** private mint only used within the initial contract */
    function mint_(
        address _to, 
        uint256 _value
    ) private {
        address _from = address(0);
        uint256 _mintable = token.mintable;
        require(
            _value >= 0 &&
            _value <= _mintable &&
            _to != address(0)
        );
        token.mintable -= _value;
        token.totalSupply += _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    /** private transfer only used within the initial contract */
    function transfer_(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0) &&
            _to != address(0) &&
            _value <= balance[_from] &&
            _value >= 0
        );
        
        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    /** public transfer */
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _from = msg.sender;
        transfer_(
            _from,
            _to,
            _value
        );
        return true;
    }
    /** public transfer from */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _spender
        uint256 _allwnc = allowed[_from][_spender]
        require(
            _allwnc != type(uint256).max &&
            _allwnc >= _value
        );

        allowed[_from][_spender] -= _value;
        transfer_(
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
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function name() public view returns (string memory) {return token.name;}
    function symbol() public view returns (string memory) {return token.symbol;}
    function decimals() public view returns (uint8) {return token.decimals;}
    function totalSupply() public view returns (uint256) {return token.totalSupply;}
    function balanceOf(
        address _owner
    ) public view returns (uint256) {return balance[_owner];}
    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {return allowed[_owner][_spender];}
}


contract PoolClosedCentalv1 {
    ERC20Capped token;
    address nativeToken;
    constructor(
        string _tokenName,
        string _tokenSymbol,
        uint8 _decimals,
        uint256 _mintable,
        uint256 _initialSupply
    ) {
        token = new ERC20Capped(
            address(this),
            _tokenName,
            _tokenSymbol,
            _decimals,
            _mintable,
            _initialSupply
        );
        nativeToken = address(token)
    }
}



/** linked pool and closed centralized */
contract State is IERC20 {
    /** ERC20 */
    struct Token {
        string name;
        string symbol;
        uint8 decimals;
        uint256 mintable;
        uint256 totalSupply;
    }
    Token internal token;
    mapping(address=>uint256) internal balance;
    mapping(address=>uint256) internal allowed;
    /** pool */
        struct Fee {
        uint256 management;
        uint256 performance;
        uint256 threshold;
        uint256 measurementStart;
        uint256 measurementReset;
    }
    struct Settings {
        bool externalTransferable;
        bool onlyWhitelisted;
        address currency;
        uint256 minDeposit;
        uint256 maxDeposit;
    }
    struct Pool {
        string name;
        string description;
        uint256 required;
        uint256 aum;
        uint256 lbt;
        uint256 nav;
        uint256 navps;
        Fee fee;
        address creator;
        uint256 creatorStake;
        Settings settings;
    }
    Pool internal pool;
    mapping(address=>uint256) internal contribution;
    /** permission */
    address internal admin;
    address internal logic;
    address internal manager;
}
contract Authenticator is State {
    /** permission */
    modifier onlyAdmin() {
        require(
            admin == msg.sender
        );
        _;
    }
    modifier onlyLogic() {
        require(
            logic == msg.sender
        );
        _;
    }
    modifier onlyManager() {
        require(
            manager == msg.sender
        );
        _;
    }
}
contract ERC20 is Authenticator {
    /** basic */
    function name() public view returns (string memory) {return token.name;}
    function symbol() public view returns (string memory) {return token.symbol;}
    function decimals() public view returns (uint8) {return token.decimals;}
    function totalSupply() public view returns (uint256) {return token.totalSupply;}
    function balanceOf(address _domain) public view returns (uint256) {return balance[_domain];}
    function transfer(address _to, uint256 _value) public returns (bool) {
        address _from = msg.sender;
        require(
            _value <= balanceOf(_from) &&
            _value >= 0 &&
            _from != address(0) &&
            _to != address(0)
        );
        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function mint(address _to, uint256 _value) public onlyLogic returns (bool) {
        address _from = address(0);
        require(
            _value <= token.mintable &&
            _value >= 0 &&
            _to != address(0)
        );
        token.mintable -= _value;
        token.totalSupply += _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function burn(address _from, uint256 _value) public onlyLogic returns (bool) {
        address _to = address(0)
        require(
            _value >= 0 &&
            _value <= balance[_from]
        );
        token.totalSupply -= _value;
        balance[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];
        require(
            _allowance != type(uint256).max &&
            _allowance >= _value &&
            _value <= balanceOf(_from) &&
            _value >= 0 &&
            _from != address(0) &&
            _to != address(0)
        );
        allowed[_from][msg.sender] -= _value;
        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        address _owner = msg.sender;
        require(
            _owner != address(0) &&
            _spender != address(0)
        );
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }
    function allowance(
        address _owner, 
        address _spender
    ) public view returns (uint256) {return allowed[_owner][_spender];}
}
/** pool | fund | index mechanic */
contract Pool is ERC20 {
    /** deposit matic | send custom erc20 token for the pool */
    function contribute(address _value) payable external returns (bool) {
        address _from = msg.sender;
        address _to = address(this);
        uint256 _required = pool.required;
        IERC20 _token = IERC20(pool.settings.currency);
        require(
            _value <= _required
        );
        _token.transferFrom(_from, _to, _value * 10**_token.decimals());
        pool.required -= _value;
        /** now send the contributor tokens */

        return true;
    }
    /** selling and buying only for manager */
}
contract Interface is Pool {
    function updateLogic(address _newLogicContract) public onlyAdmin returns (bool) {
        logic = _newLogicContract;
        return true;
    }
    function updateAdmin(address _newAdminContract) public onlyAdmin returns (bool) {
        admin = _newAdminContract;
        return true;
    }
    function updateManager(address _newManagerContract) public onlyManager returns (bool) {
        manager = _newManagerContract;
        return true;
    }
    function updatePool(
        string _name,
        string _description,
        uint256 _required,
        uint256 _aum,
        uint256 _lbt,
        uint256 _nav,
        uint256 _navps,
        uint256 _feeManagement,
        uint256 _feePerformance,
        uint256 _threshold,
        uint256 _measurementStart,
        uint256 _measurementReset,
        bool _externalTransferable,
        bool _onlyWhitelisted,
        address _currency,
        uint256 _minDeposit,
        uint256 _maxDeposit
    ) public onlyAdmin returns (bool) {
        pool.name = _name;
        pool.description = _description;
        pool.required = _required;
        pool.aum = _aum;
        pool.lbt = _lbt;
        pool.nav = _nav;
        pool.navps = _navps;
        pool.fee.management = _feeManagement;
        pool.fee.performance = _feePerformance;
        pool.fee.threshold = _threshold;
        pool.fee.measurementStart = _measurementStart;
        pool.fee.measurementReset = _measurementReset;
        pool.settings.externalTransferable = _externalTransferable;
        pool.settings.onlyWhitelisted = _onlyWhitelisted;
        pool.settings.currency = _currency;
        pool.settings.minDeposit = _minDeposit;
        pool.settings.maxDeposit = _maxDeposit;
        return true;
    }
    function fetchPool() public returns (
        string,
        string,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        bool,
        address,
        uint256,
        uint256
    ) {
        return (
            pool.name,
            pool.description,
            pool.required,
            pool.aum,
            pool.lbt,
            pool.nav,
            pool.navps,
            pool.fee.management,
            pool.fee.performance,
            pool.fee.threshold,
            pool.fee.measurementStart,
            pool.fee.measurementReset,
            pool.settings.externalTransferable,
            pool.settings.onlyWhitelisted,
            pool.settings.currency,
            pool.settings.minDeposit,
            pool.settings.maxDeposit
        );
    }
    constructor(
        address _admin,
        address _logic,
        address _manager
    ) {
        admin = _admin;
        logic = _logic;
        manager = _manager;
    }
}












contract Logic {    
    /**
    TPV START - HWM = 2000
    PERFORMANCE FEE 20%
    2000 * 0.2 = 400
     */
    constructor() {

    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Conduit {
    event Itransfer(address indexed _token, address indexed _to, uint256 _value);
    event ItransferFrom(address indexed _token, address indexed _from, address indexed _to, uint256 _value);
    event IApprove(address indexed _token, address indexed _spender, uint256 _value);
    event IBalanceOf(address indexed _token, address indexed _owner);
    event IAllowance(address indexed _token, address indexed _owner, address indexed _spender);
    
    function Itransfer(address _token, address _to, uint256 _value) internal {
        require(_token != address(0), "zero address");
        require(_to != address(0), "zero address");
        require(_value > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(_token);
        try token.transfer(_to, _value) {emit Itransfer(token, _to, _value);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function ItransferFrom(address _token, address sender, address _to, uint256 _value) internal {
        require(_token != address(0), "zero address");
        require(_sender != address(0), "zero address");
        require(_to != address(0), "zero address");
        require(_value > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(_token);
        try token.transferFrom(_sender, _to, _value) {emit ItransferFrom(token, _sender, _to, _value);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IApprove(address _token, address _spender, uint256 _value) internal {
        IERC20 token = IERC20(_token);
        try token.approve(_spender, _value) {emit IApprove(token, _spender, _value);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IBalanceOf(address _token, address _owner) internal returns (uint256) {
        IERC20 token = IERC20(_token);
        try token.balanceOf(_owner) {return token.balanceOf(_owner); emit IBalanceOf(token, _owner);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IAllowance(address _token, address _owner, address _spender) internal returns (uint256) {
        IERC20 token = IERC20(_token);
        try token.allowance(_owner, _spender) {return token.allowance(_owner, _spender); emit IAllowance(token, _owner, _spender);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }
}

// token a pool creator can issue to represent ownership of the pool also ERC20
// people must use our native currency as base currency
contract PoolToken {
    address creator;
    string immutable name;
    string immutable subSymbol;
    uint8 immutable decimals;
    uint256 totalSupply;
    uint256 immutable maxSupply; // if its an open ended fund then it will not require one

    mapping(address => uint256) internal balances;

    mapping(address => bool) internal isCreator;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Mint(address indexed _to, uint256 _value);
    event Burn(address indexed _to, uint256 _value);
    modifier creator() {
        require(isCreator[msg.sender] == true, "unauthorized");
        _;
    }

    constructor(string _name, string _subSymbol) {
        creator = msg.sender;
        name = _name;
        subSymbol = _subSymbol;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value), "insufficient balance";
        Math.sub(balances[msg.sender], _value);
        Math.add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0), "invalid address");
        require(_value > 0, "invalid value");
        Math.add(totalSupply, _value);
        Math.add(balances[_to], _value);
        emit Mint(_to, _value);
        return true;
    }

    function burn(address _to, uint256 _value) internal returns (bool) {
        require(_value > 0, "invalid value");
        require(balances[msg.sender] >= _value, "insufficient balance");
        Math.sub(totalSupply, _value);
        Math.sub(balances[msg.sender], _value);
        emit Burn(msg.sender, _value);
        return true;
    }

    // ERC20 STANDARD
    function name() public view returns (string) {return name;}
}

// decentralizing the power to create funds?? liquidity too low for a big passive invester but can trade large liquidity
contract Pool is Conduit, PoolToken { // the funding needs 
    /*
    Allowing anyone to start a fund
     */
    
    uint256 i = 0;
    mapping(uint256 => Fund) internal funds;
    struct Fund {
        uint256 index;              // ref no of the fund
        uint256 aum;                // asset under management
        uint256 lbt;                // liabilities
        uint256 nav;                // aum - lbt
        uint256 navps;              // nav / totalSupply
        uint256 uniqueContributors; // value of unique address of contributors
        uint256 feeManagement;      // management fee
        uint256 feePerformance;     // performance fee
        uint256 threshold;          // threshold before performance fees apply
        string name;                // name of the fund
        string subSymbol;           // ticker of the fund within the DREAM ecosystem
        uint8 decimals;             // decimals
        address creator;            // address of the fund creator
        uint256 creatorStake;       // amount of DREAM the creator has in the fund
        uint256 fundingRequired;    // amount of DREAM requested for the fund
        uint256 maxSupply;          // maximum possible contributions
        uint256 totalSupply;        // total amount of shares of the closed fund being minted
        bool canTransferOut;        // can this fund transfer funds out of the wallet
        uint256 minDeposit;         // min deposit per address
        uint256 maxDeposit;         // max deposit per address
    }
    mapping(uint256 => mapping(address => uint256)) fundsBalances;   // amount of fund tokens each address has per fund
    mapping(uint256 => mapping(address => uint256)) fundsVote;       // some funds may want to have decentralized governance
    mapping(uint256 => mapping(address => bool)) fundsIsWhitelisted; // some funds may want to white list who can use their fund
    mapping(uint256 => mapping(address => bool)) fundsIsCreator;     // who is the creator

    modifier newFund() {
        _;
        i++;
    }

    constructor() {}

    function createFund(string memory _name, string memory _subSymbol) external newFund returns (bool) {
        Fund memory fund = Fund({
            index: i,
            aum: 0,
            lbt: 0,
            nav: 0,
            navps: 0,
            uniqueContributors: 0,
            feeManagement: _feeManagement,
            feePerformance: _feePerformance,
            threshold: _threshold,
            name: _name,
            subSymbol: _subSymbol,
            decimals: 18,
            creator: msg.sender,
            creatorStake: 0,
            fundingRequired: _fundingRequired,
            maxSupply: _maxSupply,
            totalSupply: 0,
            canTransferOut: _canTransferOut,
            minDeposit: _minDeposit,
            maxDeposit: _maxDeposit
        });
        // the fund creator is creator
        fundsIsCreator[i][msg.sender] = true;
        fundsIsWhitelisted[i][msg.sender] = true;
        // append fund to map
        funds[i] = fund;
        return true;
    }

    function deposit(uint256 _index, uint256 _value) {
        require(_index <= i, "fund ref not found");

        // transfer x amount of our token to the address
        require(IBalanceOf(//our contract, msg.sender) >= _value);
        Itransfer()

    }

    function withdraw() {

    }
}