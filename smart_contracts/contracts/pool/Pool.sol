// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "smart_contracts/libraries/Math.sol";

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