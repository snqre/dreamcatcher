// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IDefaultImplementation02.sol";

interface IVault is IDefaultImplementation02 {

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
    function deposit(address tokenIn, uint256 amountIn) external payable;

    /**
    * @dev Withdraw ERC20 tokens from the contract. The caller must have the WITHDRAWAL_ERC20_ROLE.
    * 
    * @param to The address to which the withdrawn tokens will be sent.
    * @param tokenOut The address of the ERC20 token to withdraw.
    * @param amountOut The amount of ERC20 tokens to withdraw.
    */
    function withdrawERC20(address to, address tokenOut, uint256 amountOut) external;

    /**
    * @dev Withdraw MATIC tokens from the contract. The caller must have the WITHDRAWAL_MATIC_ROLE.
    * 
    * @param to The address to which the withdrawn tokens will be sent.
    * @param amount The amount of MATIC tokens to withdraw.
    */
    function withdrawMATIC(address to, uint256 amount) external;
}