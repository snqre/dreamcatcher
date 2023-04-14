// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

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
    event Itransfer(address indexed token, address indexed recipient, uint256 amount);
    event ItransferFrom(address indexed token, address indexed sender, address indexed recipient, uint256 amount);
    event IApprove(address indexed token, address indexed spender, uint256 amount);
    event IBalanceOf(address indexed token, address indexed account);
    event IAllowance(address indexed token, address indexed owner, address indexed spender);

    function Itransfer(address token, address recipient, uint256 amount) internal {
        require(token != address(0), "zero address");
        require(recipient != address(0), "zero address");
        require(amount > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(token);
        try token.transfer(recipient, amount) {emit Itransfer(token, recipient, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function ItransferFrom(address token, address sender, address recipient, uint256 amount) internal {
        require(token != address(0), "zero address");
        require(sender != address(0), "zero address");
        require(recipient != address(0), "zero address");
        require(amount > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(token);
        try token.transferFrom(sender, recipient, amount) {emit ItransferFrom(token, sender, recipient, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IApprove(address token, address spender, uint256 amount) internal {
        IERC20 token = IERC20(token);
        try token.approve(spender, amount) {emit IApprove(token, spender, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IBalanceOf(address token, address account) internal returns (uint256) {
        IERC20 token = IERC20(token);
        try token.balanceOf(account) {return token.balanceOf(account); emit IBalanceOf(token, account);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IAllowance(address token, address owner, address spender) internal returns (uint256) {
        IERC20 token = IERC20(token);
        try token.allowance(owner, spender) {return token.allowance(owner, spender); emit IAllowance(token, owner, spender);}
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

    constructor(address _creator, string _name, string _subSymbol) {
        creator = _creator;
        name = _name;
        subSymbol = _subSymbol;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Mint(address indexed _to, uint256 _value);

    modifier creator() {
        require(isCreator[msg.sender] == true, "unauthorized");
        _;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value), "insufficient balance";
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public creator returns (bool) {
        balances[_to] += _value;
        emit Mint(_to, _value);
        return true;
    }

    // ERC20 STANDARD
    function name() public view returns (string) {return name;}
}

// decentralizing the power to create funds?? liquidity too low for a big passive invester but can trade large liquidity
contract FundFactory is Conduit { // the funding needs 
    /*
    Allowing anyone to start a fund
     */
    struct Asset {
        address domain; // contract address of the ERC20 token
        uint256 allocation; // percentage of the fund that is allocated to this

    }

    struct Type {
        uint8 hedge = 0;
        uint8 venture = 1;
        uint8 investment = 2;
    }

    struct Pool {
        string name;
        string subTicker; // <DREAM> - <tkr>
        address creator;
        uint256 creatorStake; // does the owner have a stake in the fund
        bool isImmutable; // the fund allocations cannot be changed
        uint256 limitOfAuM; // Max amount money they want to manage
        uint256 minDepositAmount;
        bool allowedToMoveAssetsFromWallet; // can the creator move assets from the wallet
        bool allowedToShort;
        
        address[] whitelisted; // you can pick who can contribute
    }

    mapping(string => Pool) private pool;


    function newFund() public {

    }

    // will have batch transactions and delays
    
    /*
    USDT -> Fund <- Tokens (DEX vs EX)
     */
    function setAllocations() {
        // set the allocation
    }

    function singleSwap() {
        // get cheapest price from aggregator
        // make swap

        // the fund can only swap so it cannot transfer money off the fund contract
        // create


        // accumulation > early stage > 7 - 10 years > distribution

    }
    /*
    Swapping
     */
}