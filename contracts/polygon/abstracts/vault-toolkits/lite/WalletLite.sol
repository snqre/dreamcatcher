// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract Walletlite is StorageLite, Context {

    event DepositERC20(address indexed from, address indexed tokenIn, uint indexed amountIn);

    event WithdrawERC20(address indexed to, address indexed tokenOut, uint indexed amountOut);

    event DepositMATIC(address indexed from, uint indexed amountIn);

    event WithdrawMATIC(address indexed to, uint indexed amountOut);

    function balanceERC20(address token) public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____balanceERC20(token)]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____balanceERC20(token)], (uint));
    }

    function balanceMATIC() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____balanceMATIC()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____balanceMATIC()], (uint));
    }

    function ____balanceERC20(address token) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("BALANCE_ERC20", token));
    }

    function ____balanceMATIC() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("BALANCE_MATIC"));
    }

    function _depositERC20(address tokenIn, uint amountIn) internal virtual {
        IERC20Metadata token = IERC20Metadata(tokenIn);
        token.transferFrom(_msgSender(), address(this), amountIn);
        uint balance = balanceERC20(tokenIn);
        balance += amountIn;
        _bytes[____balanceERC20(tokenIn)] = abi.encode(balance);
        emit DepositERC20(_msgSender(), tokenIn, amountIn);
    }

    function _withdrawERC20(address to, address tokenOut, uint amountOut) internal virtual {
        IERC20Metadata token = IERC20Metadata(tokenOut);
        token.transfer(to, amountOut);
        uint balance = balanceERC20(tokenOut);
        balance -= amountOut;
        _bytes[____balanceERC20(tokenOut)] = abi.encode(balance);
        emit WithdrawERC20(to, tokenOut, amountOut);
    }

    function _depositMATIC() internal payable virtual {
        if (msg.value >= 1) {
            uint balance = balanceMATIC();
            balance += msg.value;
            _bytes[____balanceMATIC()] = abi.encode(balance);
            emit DepositMATIC(_msgSender(), msg.value);
        }
    }

    function _withdrawMATIC(address to, uint amountOut) internal virtual {
        address recipient = payable(to);
        require(address(this).balance() <= amountOut, "Walletlite: insufficient balance");
        recipient.transfer(amountOut);
        balance = balanceMATIC();
        balance -= amountOut;
        _bytes[____balanceMATIC()] = abi.encode(balance);
        emit WithdrawMATIC(to, amountOut);
    }
}