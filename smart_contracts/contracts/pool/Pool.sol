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

    constructor(, string _name, string _subSymbol) {
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
contract PoolOpenEnd is Conduit, PoolToken { // the funding needs 
    /*
    Allowing anyone to start a fund
     */

    uint256 aum; // assets under management
    uint256 liabilities; // liabilities
    uint256 netAssetValue; // aum - liabilities
    uint256 netAssetValuePerShare; // nav / shares
    uint256 numberOfContributors; // unique addresses who have contributed moola
    uint256 managementFee // % being taken of aum per year

    constructor() {}

    function deposit() {

    }

    function withdraw() {

    }

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

contract PoolCloseEnd {
    
}

contract PoolFactory {

}