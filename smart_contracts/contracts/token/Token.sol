// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/libraries/Math.sol";

interface IToken {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function maxSupply() public view returns (uint256);
    function totalSupply() public view returns (uint256);
    function balanceOf(address account) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function transfer(address recipient, uint256 amount) public returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
}

interface IRoleManagement {
    function grantRoleAdmin(address account) public returns (bool);      // admin can grant admin
    function revokeRoleAdmin(address account) public returns (bool);     // admin can revoke admin
    function grantRoleOwner(address account) public returns (bool);      // admin can grant owner
    function revokeRoleOwner(address account) public returns (bool);     // admin can revoke owner
    function revokeMyRoleOwner() public returns (bool);                  // owner can revoke owner
    function grantRoleValidator(address account) public returns (bool);  // admin can grant validator
    function revokeRoleValidator(address account) public returns (bool); // admin can revoke validator
    function revokeMyRoleValidator() public returns (bool);              // validator can revoke self validator
    function grantRoleExtention() public returns (bool);                 // admin can grant extension
    function revokeRoleExtension() public returns (bool);                // admin can revoke extension
    function revokeMyRoleExtension() public returns (bool);              // extension can revoke self extension
}

contract Token {
    string   immutable name          = "Dreamcatcher";
    string   immutable symbol        = "DREAM";
    uint8    immutable decimals      = 18;
    uint256  immutable totalSupply   = 200000000 * 10**decimals;
    uint256  immutable maxSupply     = 200000000 * 10**decimals;

    mapping(address => uint256) internal balances;
    mapping(address => uint256) internal votes;
    mapping(address => uint256) internal allowed;

    // PERMISSIONS
    mapping(address => bool) private isAdmin;        // highest level
    mapping(address => bool) private isOwner;        // temp role
    mapping(address => bool) private isValidator;    // exchanges native tokens for votes or has permission to do so
    mapping(address => bool) private isExtension;    // extensions are contracts that may need permissions but cannot manage roles

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event AllowanceIncreased(address indexed account, address indexed spender, uint256 increase);
    event AllowanceDecreased(address indexed account, address indexed spender, uint256 decrease);

    modifier admin() {require(isAdmin[msg.sender] == true, "only an admin can call this function");_;}
    modifier owner() {require(isOwner[msg.sender] == true, "only an owner can call this function");_;}
    modifier validator() {require(isValidator[msg.sender] == true, "only a validator can call this function");_;}
    modifier extension() {require(isExtension[msg.sender] == true, "only approved contracts can call this function");_;}

    function grantRoleAdmin(address account) public admin returns (bool) {isAdmin[account] = true; return true;}             // admin can grant admin
    function revokeRoleAdmin(address account) public admin returns (bool) {isAdmin[account] = false; return true;}           // admin can revoke admin
    function grantRoleOwner(address account) public admin returns (bool) {isOwner[account] = true; return true;}             // admin can grant owner
    function revokeRoleOwner(address account) public admin returns (bool) {isOwner[account] = false; return true;}           // admin can revoke owner
    function revokeMyRoleOwner() public owner returns (bool) {isOwner[msg.sender] = false; return true;}                        // owner can revoke self owner
    function grantRoleValidator(address account) public admin returns (bool) {isValidator[account] = true; return true;}     // admin can grant validator
    function revokeRoleValidator(address account) public admin returns (bool) {isValidator[account] = false; return true;}   // admin can revoke validator
    function revokeMyRoleValidator() public validator returns (bool) {isValidator[msg.sender] = false; return true;}            // validator can revoke self validator
    function grantRoleExtension(address account) public admin  returns (bool) {isExtension[account] = true; return true;}                   // admin can grant extension
    function revokeRoleExtension(address account) public admin returns (bool) {isExtension[account] = false; return true;}                   // admin can revoke extension
    function revokeMyRoleExtension() public extension returns (bool) {isExtension[msg.sender] = false; return true;}             // extension can revoke self extension

    function approve(address spender, uint256 amount) public returns (bool) {
        require(msg.sender != address(0), "zero address");
        require(spender != address(0), "zero address");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {   
        require(msg.sender != address(0), "zero address");
        require(spender != address(0), "zero address");
        uint256 x = allowance(msg.sender, spender);
        uint256 y = addedValue;
        allowed[msg.sender][spender] = Math.add(x, y);
        emit AllowanceIncreased(msg.sender, spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "decrease allowance below zero");
        unchecked {
            require(msg.sender != address(0), "zero address");
            require(spender != address(0), "zero address");
            uint256 x = currentAllowance;
            uint256 y = subtractedValue;
            allowed[msg.sender][spender] = Math.sub(x, y);
        }
        emit AllowanceDecreased(msg.sender, spender, subtractedValue);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balances[sender] >= amount, "insufficient balance");
        require(allowed[sender][msg.sender] >= amount, "transfer amount exceeds allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // ERC 20 STANDARD
    function name() public view returns (string) {return name;}
    function symbol() public view returns (string) {return symbol;}
    function decimals() public view returns (uint8) {return decimals;}
    function maxSupply() public view returns (uint256) {return maxSupply;}
    function totalSupply() public view returns (uint256) {return totalSupply;}
    function balanceOf(address account) public view returns (uint256) {return balances[account];}
    function allowance(address owner, address spender) public view returns (uint256) {return allowed[owner][spender];}

    constructor(address governorContract) {
        isAdmin[msg.sender] = true;          // token contract has admin
        isAdmin[governorContract] = true;    // gov contract has admin
    }
}

interface IERC20 {
    // OPTIONAL
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    
    // STANDARD
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Conduit is Token {
    event Itransfer(address indexed token, address indexed recipient, uint256 amount);
    event ItransferFrom(address indexed token, address indexed sender, address indexed recipient, uint256 amount);
    event IApprove(address indexed token, address indexed spender, uint256 amount);
    event IBalanceOf(address indexed token, address indexed account);
    event IAllowance(address indexed token, address indexed owner, address indexed spender);

    function Itransfer(address token, address recipient, uint256 amount) public checkConduitIsPaused onlyAdmin {
        require(token != address(0), "zero address");
        require(recipient != address(0), "zero address");
        require(amount > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(token);
        try token.transfer(recipient, amount) {emit Itransfer(token, recipient, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function ItransferFrom(address token, address sender, address recipient, uint256 amount) public checkConduitIsPaused onlyAdmin {
        require(token != address(0), "zero address");
        require(sender != address(0), "zero address");
        require(recipient != address(0), "zero address");
        require(amount > 0, "transfer amount is equal or less than zero");
        IERC20 token = IERC20(token);
        try token.transferFrom(sender, recipient, amount) {emit ItransferFrom(token, sender, recipient, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IApprove(address token, address spender, uint256 amount) public checkConduitIsPaused onlyAdmin {
        IERC20 token = IERC20(token);
        try token.approve(spender, amount) {emit IApprove(token, spender, amount);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IBalanceOf(address token, address account) public checkConduitIsPaused returns (uint256) {
        IERC20 token = IERC20(token);
        try token.balanceOf(account) {return token.balanceOf(account); emit IBalanceOf(token, account);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }

    function IAllowance(address token, address owner, address spender) public checkConduitIsPaused onlyAdmin returns (uint256) {
        IERC20 token = IERC20(token);
        try token.allowance(owner, spender) {return token.allowance(owner, spender); emit IAllowance(token, owner, spender);}
        catch Error(string memory message) {revert(message);}
        catch {revert();}
    }
}

contract Vault is Conduit {
    mapping(string => address) internal tokens;
    function initializeVault() internal {
        // deploy with pre existing contracts likely what we'll be selling the token for at first
        tokens["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokens["WBTC"] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        tokens["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        // spawn all the supply within the vault
        balances[msg.sender] = totalSupply;
    }

    function newSupportedTokenContract(string memory symbol, address token) public admin {
        require(tokens[symbol] != token, "token already supported");
        tokens[symbol] = token;
    }

    function delSupportedTokenContract(string memory symbol) public admin {
        delete tokens[symbol];
    }
}
