// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/access/Ownable.sol";

contract Vault is Ownable {
    constructor() Ownable() {
        _transferOwnership(msg.sender);
    }
}

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";       
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";

interface IVault {
    event DepositERC20(address indexed contract_, address indexed from, uint value);
    event Deposit(address indexed from, uint value);

    event WithdrawERC20(address indexed contract_, address indexed to, uint value);
    event Withdraw(address indexed to, uint value);
}

contract Vault is IVault, Pausable, Ownable, ReentrancyGuard {

    address[] internal contracts;

    uint internal balance;

    mapping(address => bool) internal isRegisteredContract;
    mapping(address => uint) internal amounts;

    mapping(address => bool) internal isBoard;
    
    mapping(address => bool) internal hasSignedDeposit;
    mapping(address => bool) internal hasSignedWithdraw;

    uint64 timeout;

    struct SignatureSchedule {
        uint64 startTimestamp;
        uint64 expiryTimestamp;
        bool success;
    }

    uint signatureScheduleCount;

    mapping(uint => SignatureSchedule) internal signatureSchedules;

    constructor() Ownable() {
        timeout = 24 hours;
    }

    function _newSignatureSchedule() internal returns (SignatureSchedule) {
        signatureScheduleCount ++;
        uint id = signatureScheduleCount;
        uint64 now_ = block.timestamp;
        return signatureSchedules[id] = SignatureSchedule({
            startTimestamp: now_,
            expiryTimestamp: now_ + timeout,
            success: false
        });
    }

    function deposit(address contract_, address from, uint value) public payable nonReentrant onlyOwner returns (bool) {
        // transfer ethers
        if (contract_ == address(0) && from == address(0) && value == 0) {
            require(msg.value >= 1, "msg.value < 1");
            balance += msg.value;
            emit Deposit(msg.sender, msg.value);
            return true;
        }

        // transfer tokens
        else {
            require(contract_ != address(0), "contract == address(0)");
            require(from != address(0), "from == address(0)");
            require(value >= 1, "value < 1");
            require(msg.value == 0, "msg.value != 0");

            bool transferFromSuccess = IERC20(contract_).transferFrom(from, address(this), value);
            require(transferFromSuccess, "transferFrom not successful");
            
            if (isRegisteredContract[contract_] == false) {
                contracts.push(contract_);
            }

            amounts[contract_] += value;
            emit DepositERC20(contract_, from, value);
            return true;
        }
    }

    function withdraw(address contract_, address to, uint value) public nonReentrant onlyOwner returns (bool) {
        require(value >= 1, "value < 1");
        require(to != address(0), "to == address(0)");

        // transfer ethers
        if (contract_ == address(0)) {
            
            address payable recipient = payable(to);
            recipient.transfer(value);
            balance -= value;

            emit Withdraw(recipient, value);
            return true;
        }

        // transfer tokens
        else {
            require(contract_ != address(0), "contract == address(0)");

            bool transferSuccess = IERC20(contract_).transfer(to, value);
            require(transferSuccess, "transfer unsuccessful");
            amounts[contract_] -= value;

            emit WithdrawERC20(contract_, to, value);
            return true;
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}