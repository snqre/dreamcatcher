// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/DefaultImplementation02.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract Vault is DefaultImplementation02 {

    /**
    * @dev Emitted when an ERC20 deposit is made.
    * 
    * @param from The address from which the ERC20 tokens are deposited.
    * @param tokenIn The address of the ERC20 token being deposited.
    * @param amountIn The amount of ERC20 tokens deposited.
    */
    event DepositERC20(address indexed from, address indexed tokenIn, uint256 indexed amountIn);

    /**
    * @dev Emitted when MATIC (Polygon) is deposited.
    * 
    * @param from The address from which MATIC is deposited.
    * @param amount The amount of MATIC deposited.
    */
    event DepositMATIC(address indexed from, uint256 indexed amount);

    /**
    * @dev Emitted when an ERC-20 token is withdrawn.
    * 
    * @param to The address to which the ERC-20 tokens are withdrawn.
    * @param tokenOut The address of the ERC-20 token being withdrawn.
    * @param amountOut The amount of ERC-20 tokens withdrawn.
    */
    event WithdrawalERC20(address indexed to, address indexed tokenOut, uint256 indexed amountOut);

    /**
    * @dev Emitted when Matic tokens are withdrawn.
    * 
    * @param to The address to which the Matic tokens are withdrawn.
    * @param amount The amount of Matic tokens withdrawn.
    */
    event WithdrawalMATIC(address indexed to, uint256 indexed amount);

    /**
    * @dev Deposit tokens into the contract. If the deposited token is Matic (ETH), send the amount as value.
    * 
    * @param tokenIn The address of the token being deposited. Use address(0) for Matic (ETH).
    * @param amountIn The amount of tokens to deposit. For Matic (ETH), send the amount as value.
    */
    function deposit(address tokenIn, uint256 amountIn) public payable virtual {
        _deposit(tokenIn, amountIn);
    }

    /**
    * @dev Withdraw ERC20 tokens from the contract. The caller must have the WITHDRAWAL_ERC20_ROLE.
    * 
    * @param to The address to which the withdrawn tokens will be sent.
    * @param tokenOut The address of the ERC20 token to withdraw.
    * @param amountOut The amount of ERC20 tokens to withdraw.
    */
    function withdrawERC20(address to, address tokenOut, uint256 amountOut) public virtual {
        requireRole("WITHDRAWAL_ERC20_ROLE", msg.sender);
        _withdrawERC20(to, tokenOut, amountOut);
    }

    /**
    * @dev Withdraw MATIC tokens from the contract. The caller must have the WITHDRAWAL_MATIC_ROLE.
    * 
    * @param to The address to which the withdrawn tokens will be sent.
    * @param amount The amount of MATIC tokens to withdraw.
    */
    function WithdrawMATIC(address to, uint256 amount) public virtual {
        requireRole("WITHDRAWAL_MATIC_ROLE", msg.sender);
        _withdrawMATIC(to, amount);
    }

    /**
    * @dev Initialize the contract with a specified terminal address. This function is called during deployment.
    * 
    * @param terminal The address of the terminal contract that will be associated with this contract.
    */
    function _initialize(address terminal) internal virtual override {
        super._initialize(terminal);
    }

    /**
    * @dev Deposit ERC20 tokens or MATIC (native token) into the contract. 
    * If `amountIn` is greater than 0, ERC20 tokens will be transferred from the sender's address to this contract.
    * If `msg.value` is greater than 0, MATIC (native token) will be deposited into the contract.
    * 
    * @param tokenIn The address of the ERC20 token to be deposited (set to the zero address for MATIC deposits).
    * @param amountIn The amount of ERC20 tokens to deposit (set to 0 for MATIC deposits).
    */
    function _deposit(address tokenIn, uint256 amountIn) internal payable virtual {
        if (amountIn != 0) {
            IERC20Metadata token = IERC20Metadata(tokenIn);
            token.transferFrom(msg.sender, address(this), amountIn);
            emit DepositERC20(msg.sender, tokenIn, amountIn);
        }
        if (msg.value != 0) {
            emit DepositMATIC(msg.sender, msg.value);
        }
    }

    /**
    * @dev Withdraw ERC20 tokens from the contract and transfer them to the specified address.
    * 
    * @param to The address to which the withdrawn ERC20 tokens will be transferred.
    * @param tokenOut The address of the ERC20 token to be withdrawn.
    * @param amountOut The amount of ERC20 tokens to withdraw.
    * 
    * Requirements:
    * - The caller must have the `WITHDRAWAL_ERC20_ROLE` role.
    */
    function _withdrawERC20(address to, address tokenOut, uint256 amountOut) internal virtual {
        IERC20Metadata token = IERC20Metadata(tokenIn);
        token.transfer(to, amountOut);
        emit WithdrawalERC20(to, tokenOut, amountOut);
    }

    /**
    * @dev Withdraw MATIC (native token) from the contract and transfer it to the specified address.
    * 
    * @param to The address to which the withdrawn MATIC will be transferred.
    * @param amount The amount of MATIC to withdraw.
    * 
    * Requirements:
    * - The caller must have the `WITHDRAWAL_MATIC_ROLE` role.
    */
    function _withdrawMATIC(address to, uint256 amount) internal virtual {
        payable(msg.sender).transfer(amount);
        emit WithdrawalMATIC(to, amount);
    }
}