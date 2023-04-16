// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RESTARTED, I THINK I CAN DO IT BETTER
// WE CANT USE OPENZEPPELIN BECAUSE THEY DONT ALLOW US TO FLEXIBLY EDIT
// BUT WILL BE BORROWING SOME OF THEIR BASE LINE FRAMEWORKS

/// @notice Token Contract
/// @dev It does token stuff and hurts my brain
/// @author Marco

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol";


inteface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function totalSupply() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    // META DATA
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IERC20Permit {
    function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external;
    function nonces(address _owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library LibToken {
    // Its more gas efficient to store stings as bytes and convert them to string only when needed
    function getBytesAsString(bytes _bytes) internal view returns (string memory) {
        return string(_bytes) // converts bytes to string
    }

    function setStringAsBytes(string memory _string) internal view returns (bytes) {
        return bytes(_string);
    }

    // apparently openzeppelin thinks we should not access msg.sender directly so we'll do it this way
    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgData() internal view returns (bytes calldata) {
        return msg.data;
    }

}

contract Token is IERC20, IERC20Permit, EIP712 {
    // var_ :: because function names conflict with ERC20 get functions
    bytes private name_;
    bytes private symbol_;
    uint256 private totalSupply_;
    uint256 private immutable maxSupply_;
    mapping(address=>uint256) private balances;
    mapping(address=>mapping(address=>uint256)) private allowances;

    // ERC20 PERMIT
    using Counters for Counters.Counter;
    mapping(address=>Counters.Counter) private nonces;
    bytes32 private constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private PERMIT_TYPEHASH_DEPRECATED_SLOT;

    constructor() EIP712(LibToken.getBytesAsString("Dreamcatcher", "1") {
        name_ = LibToken.setStringAsBytes("Dreamcatcher");
        symbol_ = LibToken.setStringAsBytes("DREAM");
        totalSupply_ = 0;
        maxSupply_ = 200000000 * 10**18; // 200 million
    }
    
    // PERMIT
    function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public {
        require(block.timestamp <= _deadline, "expired deadline");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, useNonce(_owner), _deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, _v, _r, _s);
        require(signer == _owner, "invalid signature");
        // approve function from erc20 owner, spender, value
        require(_owner != address(0), "approve from the zero address");
        require(_spender != address(0), "approve to the zero address");
        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }
    
    // PERMIT
    function nonces(address _owner) public view returns (uint256) {return nonces[_owner].current();}
    function DOMAIN_SEPARATOR() external view returns (bytes32) {return _domainSeparatorV4();}
    function useNonce(address _owner) internal returns (uint256 current) {
        Counters.Counter storage nonce = nonces[_owner];
        current = nonce.current();
        nonce.increment();
    }
    // ERC20
    function maxSupply() public view returns (uint256) {return maxSupply_;}  // a function name that actually makes sense
    function cap() public view returns (uint256) {return maxSupply_;}        // openzeppelin format for those expecting openzeppelin
    function name() public view returns (string memory) {return LibToken.getBytesAsString(name_);}
    function symbol() public view returns (string memory) {return LibToken.getBytesAsString(symbol_);}
    function decimals() public view returns (uint8) {return 18;}
    function totalSupply() public view returns (uint256) {return totalSupply_;}
    function balanceOf(address _owner) public view returns (uint256) {return balances[_owner];}
    function transfer(address _to, uint256 _amount) public returns (bool) {
        address from = LibToken.msgSender();
        require(from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        beforeTokenTransfer(from, _to, _amount);
        require(balances[from] >= _amount, "transfer amount exceeds balance");
        unchecked {
            balances[from] -= _amount;
            balances[_to] += _amount;
        }
        emit Transfer(from, _to, _amount);
        _afterTokenTransfer(from, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        address owner = LibToken.msgSender();
        require(owner != address(0), "approve from the zero address");
        require(_spender != address(0), "approve to the zero address");
        allowances[owner][_spender] = amount;
        emit Approval(owner, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        address spender = LibToken.msgSender();
        // spend allowance from, spender, amount
        uint256 currentAllowance = allowance(_from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _amount, "insufficient allowance");
            unchecked {
                // owner, spender, currentAllowance - amount
                require(_from != address(0), "approve from the zero address");
                require(spender != address(0), "approve to the zero address");
                allowances[_from][spender] = amount;
                emit Approval(_from, spender, amount);
            }
        }
        // transfer from, to, amount
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        beforeTokenTransfer(_from, _to, _amount);
        require(balances[_from] >= _amount, "transfer amount exceeds balance");
        unchecked {
            balances[_from] -= _amount;
            balances[_to] += _amount;
        }
        emit Transfer(_from, _to, _amount);
        afterTokenTransfer(_from, _to, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        address owner = LibToken.msgSender();
        // owner, spender, allowance(owner, spender) + addedValue
        require(owner != address(0), "approve from the zero address");
        require(_spender != address(0), "approve to the zero address");
        amount = allowance(owner, _spender) + _addedValue;
        allowances[owner][_spender] = amount;
        emit Approval(owner, _spender, amount);
        return true;
    }
    
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        address owner = LibToken.msgSender();
        uint256 currentAllowance = allowance(owner, _spender);
        require(currentAllowance >= _subtractedValue. "decrease allowance below zero");
        unchecked {
            // owner | spender | currentAllowance - subtractedValue
            require(owner != address(0), "approve from the zero address");
            require(_spender != address(0), "approve to the zero address");
            amount = currentAllowance - subtractedValue;
            allowances[owner][_spender] = amount;
            emit Approval(owner, _spender, amount);
        }
        return true;
    }

    // merged ERC20 && ERC20Capped
    function mint(address _to, uint256 _amount) internal {
        require(totalSupply() + _amount <= maxSupply(), "cap exceeded");
        require(_to != address(0), "mint to the zero address");
        beforeTokenTransfer(address(0), _to, _amount);
        totalSupply_ += _amount;
        unchecked {
            balances[_to] += _amount;
        }
        emit Transfer(address(0), _to, _amount);
        afterTokenTransfer(address(0), _to, _amount);
    }

    function burn(address _from, uint256 _amount) internal {
        require(_from != address(0), "burn from the zero address");
        beforeTokenTransfer(_from, address(0), _amount);
        require(balances[_from] >= _amount, "burn amount exceeds balance");
        unchecked {
            balances[_from] -= _amount;
            totalSupply_ -= amount;
        }
        emit Transfer(_from, address(0), _amount);
        afterTokenTransfer(_from, address(0), _amount);
    }

    // before transfers
    function beforeTokenTransfer(address _from, address _to, uint256 _amount) internal {

    }
    // after transfers
    function afterTokenTransfer(address _from, address _to, uint256 _amount) internal {

    }

}