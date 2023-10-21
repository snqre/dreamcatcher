// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract BankableLite is StorageLite, Context {

    event SenderDepositERC20(address indexed sender, address indexed tokenIn, uint indexed amountIn);

    event SenderWithdrawERC20(address indexed sender, address indexed tokenOut, uint indexed amountOut);

    event SenderDepositMATIC(address indexed sender, uint amountIn);

    event SenderWithdrawMATIC(address indexed sender, uint amountOut);

    function balanceOf(address account, address erc20) public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____balanceOf(account, erc20)]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____balanceOf(account, erc20)], (uint));
    }

    function balanceOfMATIC(address account) public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____balanceOfMATIC(account)]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____balanceOfMATIC(account)], (uint));
    }

    function ____balanceOf(address account, address erc20) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("BALANCE_OF", account, erc20));
    }

    function ____balanceOfMATIC(address account) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("BALANCE_OF_MATIC", account));
    }

    function _senderDepositERC20(address tokenIn, uint amountIn) internal virtual {
        IERC20Metadata token = IERC20Metadata(tokenIn);
        uint balanceOf = token.balanceOf(_msgSender());
        require(balanceOf >= amountIn, "BankableLite: insufficient balance");
        token.transferFrom(_msgSender(), address(this), amount);
        uint balance = balanceOf(_msgSender(), tokenIn);
        balance += amountIn;
        _bytes[____balanceOf(_msgSender(), tokenIn)] = abi.encode(balance);
        emit SenderDepositERC20(_msgSender(), tokenIn, amountIn);
    }

    function _senderWithdrawERC20(address tokenOut, uint amountOut) internal virtual {
        IERC20Metadata token = IERC20Metadata(tokenOut);
        uint balanceOf = balanceOf(_msgSender(), tokenOut);
        require(amountOut <= balanceOf, "BankableLite: insufficient balance");
        token.transfer(_msgSender(), amountOut);
        balanceOf -= amountOut;
        _bytes[____balanceOf(_msgSender(), tokenOut)] = abi.encode(balanceOf);
        emit SenderWithdrawERC20(_msgSender(), tokenOut, amountOut);
    }

    function _senderDepositMATIC() internal payable virtual {
        uint balanceOf = balanceOfMATIC(_msgSender());
        balanceOf += msg.value;
        _bytes[____balanceOfMATIC(_msgSender())] = abi.encode(balanceOf);
        emit SenderDepositMATIC(_msgSender(), msg.value);
    }

    function _senderWithdrawMATIC(uint amountOut) internal virtual {
        address recipient = payable(_msgSender());
        uint balanceOf = balanceOfMATIC(_msgSender());
        require(balanceOf >= amountOut, "BankableLite: insufficient balance");
        recipient.transfer(amountOut);
        emit SenderWithdrawMATIC(_msgSender(), amountOut);
    } 
}