// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/libraries/__Finance.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/IERC20Mintable.sol";
import "contracts/polygon/ERC20Mintable.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/external/openzeppelin/security/Pausable.sol";
import "contracts/polygon/external/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

contract SolsticeVault is Ownable, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
    * @notice Private state variables used in the SolsticeVault contract.
    */
    bool private _initialized;
    address private _denominator;
    UniswapV2[] private _uniswapV2s;
    ERC20Mintable private _erc20;
    EnumerableSet.AddressSet private _allowedIn;
    EnumerableSet.AddressSet private _all;

    /**
    * @notice A data structure representing information about a Uniswap V2 instance.
    * @dev This struct includes the name of the Uniswap instance, the address of its factory contract, and the address of its router contract.
    */
    struct UniswapV2 {
        /**
        * A data structure representing information about a Uniswap V2 instance.
        * This struct includes the name of the Uniswap instance, the address
        * of its factory contract, and the address of its router contract.
        */
        string name;
        address factory;
        address router;
    }

    /**
    * @notice Modifier to ensure that a function can only be called when the mean price of a specified token is not zero.
    * @dev This modifier checks the mean price of the token using the Finance contract and ensures it's not zero before proceeding.
    * @param tokenIn The address of the token for which the mean price is checked.
    * @dev Use this modifier to restrict functions to be called only when the mean price of a specified token is non-zero.
    */
    modifier onlyNotZeroValue(address tokenIn) {
        _onlyNotZeroValue(tokenIn);
        _;
    }

    /**
    * @notice Modifier to enforce that a function can only be called when the contract is already initialized.
    * @dev This modifier checks whether the contract is in the initialized state before allowing the function to proceed.
    * @dev Use this modifier to restrict certain functions to be called only after the contract has been initialized.
    */
    modifier whenInitialized() {
        _whenInitialized();
        _;
    }

    /**
    * @notice Modifier to enforce that a function can only be called when the contract is not yet initialized.
    * @dev This modifier checks whether the contract is in the uninitialized state before allowing the function to proceed.
    * @dev Use this modifier to restrict certain functions from being called after the contract has been initialized.
    */
    modifier whenNotInitialized() {
        _whenNotInitialized();
        _;
    }

    /**
    * @notice Modifier to log and allow a specific token before executing a function.
    * @dev This modifier adds the specified token to the set of allowed tokens and then allows the function to proceed.
    * @param tokenIn The address of the token to be logged and allowed.
    * @dev This modifier is typically used to ensure that the specified token is allowed before executing the function.
    */
    modifier log(address tokenIn) {
        _addAllowedIn(tokenIn);
        _;
    }

    /**
    * @notice Emitted when a token swap occurs in the SolsticeVault.
    * @param router The address of the Uniswap V2 router used for the swap.
    * @param tokenIn The address of the token being swapped.
    * @param tokenOut The address of the token received in the swap.
    * @param amountIn The amount of tokens being swapped.
    * @param slippage The allowed slippage percentage for the swap.
    */
    event Swap(address indexed router, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 slippage);

    /**
    * @notice Emitted when a withdrawal is made from the SolsticeVault.
    * @param account The address of the account making the withdrawal.
    * @param amountIn The amount of tokens being withdrawn.
    */
    event Withdrawal(address indexed account, uint256 indexed amountIn);

    /**
    * @notice Emitted when a deposit is made into the SolsticeVault.
    * @param account The address of the account making the deposit.
    * @param tokenIn The address of the token being deposited.
    * @param amountIn The amount of the token being deposited.
    */
    event Deposit(address indexed account, address indexed tokenIn, uint256 indexed amountIn);

    /**
    * @notice Emitted when a token is added to the list of allowed tokens for deposits and holds in the SolsticeVault.
    * @param tokenIn The address of the token that is allowed.
    */
    event TokenAllowedIn(address indexed tokenIn);

    /**
    * @notice Emitted when the SolsticeVault contract is initialized by providing initial liquidity.
    * @param account The address of the account that triggered the initialization.
    * @dev Use this event to track the initialization of the SolsticeVault contract.
    */
    event Initialized(address indexed account);

    /**
    * @notice Constructor for initializing the SolsticeVault contract.
    * @param name The name of the ERC20 token to be created by the SolsticeVault.
    * @param symbol The symbol of the ERC20 token to be created by the SolsticeVault.
    * @dev Initializes the contract by creating an ERC20 token, configuring UniswapV2 pairs, and adding allowed tokens.
    *      The contract owner is set to the deployer, and the denominator token is added to the allowed tokens.
    *      Other tokens are added based on the provided addresses, and the contract is marked as not initialized.
    */
    constructor(string memory name, string memory symbol) Ownable(msg.sender) {
        _erc20 = new ERC20Mintable(name, symbol, address(this));
        _pushUniswapV2("quickswap", 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32, 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
        _pushUniswapV2("sushiswap", 0xc35DADB65012eC5796536bD9864eD8773aBc74C4, 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        _pushUniswapV2("meshswap", 0x9F3044f7F9FC8bC9eD615d54845b4577B833282d, 0x10f4A785F458Bc144e3706575924889954946639);
        _transferOwnership(msg.sender);
        _denominator = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
        _addAllowedIn(denominator());
        _addAllowedIn(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
        _addAllowedIn(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        _addAllowedIn(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        _addAllowedIn(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
        _addAllowedIn(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6);

    }

    /**
    * @notice Retrieves the address of the ERC20 token used by the SolsticeVault.
    * @return The address of the ERC20 token.
    * @dev This function returns the address of the ERC20 token used by the SolsticeVault, providing transparency on the specific token contract associated with the vault.
    */
    function token() public view returns (address) {
        return address(_erc20);
    }

    /**
    * @notice Retrieves the name of the vault's ERC20 token.
    * @return The name of the ERC20 token.
    * @dev This function returns the name of the vault's ERC20 token, providing a human-readable representation of the token's name.
    */
    function name() public view returns (string memory) {
        return _erc20.name();
    }

    /**
    * @notice Retrieves the symbol of the vault's ERC20 token.
    * @return The symbol of the ERC20 token.
    * @dev This function returns the symbol of the vault's ERC20 token, providing a shorthand representation of the token's name.
    */
    function symbol() public view returns (string memory) {
        return _erc20.symbol();
    }

    /**
    * @notice Retrieves the number of decimals used by the vault's ERC20 token.
    * @return The number of decimals used by the ERC20 token.
    * @dev This function returns the number of decimals used by the vault's ERC20 token, providing information about the token's precision.
    */
    function decimals() public view returns (uint8) {
        return _erc20.decimals();
    }

    /**
    * @notice Retrieves the total supply of vault tokens in the SolsticeVault.
    * @return The total supply of vault tokens.
    * @dev This function returns the total supply of vault tokens, which are ERC20 tokens representing ownership in the SolsticeVault.
    */
    function supply() public view returns (uint256) {
        return _erc20.totalSupply();
    }

    /**
    * @notice Retrieves an array of addresses representing the Uniswap V2 factory contracts associated with the SolsticeVault.
    * @return An array of addresses representing the Uniswap V2 factory contracts.
    * @dev This function returns an array of addresses representing the Uniswap V2 factory contracts associated with the SolsticeVault. It ensures that the length of the array is greater than or equal to 1 before creating and populating the array.
    */
    function factories() public view returns (address[] memory) {
        /**
        * Retrieves an array of addresses representing the Uniswap V2 factory contracts
        * associated with the SolsticeVault. This function returns an array of addresses
        * representing the Uniswap V2 factory contracts associated with the SolsticeVault.
        * It ensures that the length of the array is greater than or equal to 1 before
        * creating and populating the array.
        */
        uint256 length = _uniswapV2s.length;
        require(length >= 1, "SolsticeVault: length is zero");
        address[] memory factories;
        factories = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            factories[i] = _uniswapV2s[i].factory;
        }
        return factories;
    }

    /**
    * @notice Retrieves the address of the denominator token used in the SolsticeVault.
    * @return The address of the denominator token.
    * @dev This function returns the address of the denominator token, which is used as a reference for calculating values and balances within the SolsticeVault.
    */
    function denominator() public view returns (address) {
        /**
        * Retrieves the address of the denominator token used in the SolsticeVault.
        * This function returns the address of the denominator token, which is used
        * as a reference for calculating values and balances within the SolsticeVault.
        */
        return _denominator;
    }

    /**
    * @notice Retrieves the total balance of the SolsticeVault.
    * @return The calculated net asset value of the vault, considering the balances of all supported tokens in the vault against the denominator token.
    * @dev This function leverages the Finance library's `netAssetValue` function to determine the total balance of the SolsticeVault. It considers the balances of all supported tokens in the vault relative to the denominator token.
    */
    function balance() public view returns (uint256) {
        /**
        * Retrieves the total balance of the SolsticeVault.
        * This function leverages the Finance library's `netAssetValue` function
        * to determine the total balance of the SolsticeVault. It considers the
        * balances of all supported tokens in the vault relative to the denominator token.
        */
        return __Finance.netAssetValue(factories(), _all.values(), denominator());
    }

    /**
    * @notice Calculates the value per token in the SolsticeVault.
    * @return The calculated value per token, representing the value of each vault token based on the total balance and total supply of vault tokens.
    * @dev This function computes the value per token by dividing the total balance of the vault by the total supply of vault tokens.
    */
    function valuePerToken() public view returns (uint256) {
        /**
        * Calculates the value per token in the SolsticeVault.
        * This function computes the value per token by dividing the total balance
        * of the vault by the total supply of vault tokens.
        */
        return balance() / supply();
    }

    /**
    * @notice Process of giving initial liquidity
    * @param tokenIn The address of the token to be used for providing liquidity.
    * @param amountIn The amount of the token to be provided as liquidity.
    * @param initialSupply The initial supply of your ERC-20 token.
    *
    * WARNING: This should be a very small amount as it is locked
    *          within the contract.
    */
    function initialize(address tokenIn, uint256 amountIn, uint256 initialSupply) public onlyOwner() whenNotPaused() nonReentrant() whenNotInitialized() onlyNotZeroValue(tokenIn) log(tokenIn) {
        IERC20Metadata(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        _erc20.mint(msg.sender, _convertToWei(initialSupply));
        _initialized = true;
        emit Initialized(msg.sender);
    }

    /**
    * @notice Allows users to deposit a specified amount of tokens into the SolsticeVault.
    * @param tokenIn The address of the token to be deposited.
    * @param amountIn The amount of the token to be deposited.
    * @dev This function ensures that the contract is not in a paused state and guards against reentrancy attacks. It first checks and performs actions before the deposit using the internal `_beforeDeposit` function, which includes validations, value calculations, and token transfers. After a successful deposit, it calls the internal `_afterDeposit` function to handle post-deposit actions, such as calculating minting amounts and minting tokens to the depositor's address.
    */
    function deposit(address tokenIn, uint256 amountIn) public whenNotPaused() nonReentrant() whenInitialized() onlyNotZeroValue(tokenIn) {
        /**
        * Allows users to deposit a specified amount of tokens into the SolsticeVault.
        * This function ensures that the contract is not in a paused state and guards
        * against reentrancy attacks. It first checks and performs actions before the
        * deposit using the internal `_beforeDeposit` function, which includes validations,
        * value calculations, and token transfers. After a successful deposit, it calls
        * the internal `_afterDeposit` function to handle post-deposit actions, such as
        * calculating minting amounts and minting tokens to the depositor's address.
        */
        _beforeDeposit(tokenIn, amountIn);
        _afterDeposit(tokenIn, amountIn);
        emit Deposit(msg.sender, tokenIn, amountIn);
    }

    /**
    * @notice Allows users to withdraw a specified amount of tokens from the SolsticeVault.
    * @param amountIn The amount of tokens to be withdrawn.
    * @dev This function ensures that the contract is not in a paused state and guards against reentrancy attacks. It first checks and performs actions before the withdrawal using the internal `_beforeWithdraw` function, which includes validations, token transfers, and burning of vault tokens. After a successful withdrawal, it calls the internal `_afterWithdraw` function to handle post-withdrawal actions, such as calculating repayment values and initiating repayments in the denominator or in kind. In case of a deficit, emergency withdrawals are enabled to allow depositors to withdraw the owed value in any token or tokens directly from the vault.
    */
    function withdraw(uint256 amountIn) public nonReentrant() whenInitialized() {
        /**
        * Allows users to withdraw a specified amount of tokens from the SolsticeVault.
        * This function ensures that the contract is not in a paused state and guards
        * against reentrancy attacks. It first checks and performs actions before the
        * withdrawal using the internal `_beforeWithdraw` function, which includes
        * validations, token transfers, and burning of vault tokens. After a successful
        * withdrawal, it calls the internal `_afterWithdraw` function to handle
        * post-withdrawal actions, such as calculating repayment values and initiating
        * repayments in the denominator or in kind. In case of a deficit, emergency
        * withdrawals are enabled to allow depositors to withdraw the owed value in any
        * token or tokens directly from the vault.
        */
        _beforeWithdraw(amountIn);
        _afterWithdraw(amountIn);
        emit Withdrawal(msg.sender, amountIn);
    }

    /**
    * @notice Allows the owner to initiate a token swap using a specified Uniswap V2 router.
    * @param router The index of the Uniswap V2 router from the list of registered routers.
    * @param tokenIn The address of the token to be swapped.
    * @param tokenOut The address of the desired output token.
    * @param amountIn The amount of tokens to be swapped.
    * @param slippage The allowable slippage percentage for the swap.
    * @dev This function ensures that the contract is not in a paused state and is only callable by the owner. It performs actions before the swap using the internal `_beforeSwap` function, which includes validations and initiates the token swap using the Finance library's `swapTokensSlippage` function. After a successful swap, it calls the internal `_afterSwap` function to handle post-swap actions.
    */
    function swap(uint256 router, address tokenIn, address tokenOut, uint256 amountIn, uint256 slippage) public onlyOwner() whenNotPaused() nonReentrant() whenInitialized() onlyNotZeroValue(tokenIn) {
        _beforeSwap(router, tokenIn, tokenOut, amountIn, slippage);
        _afterSwap(router, tokenIn, tokenOut, amountIn, slippage);
        emit Swap(_uniswapV2s[router].router, tokenIn, tokenOut, amountIn, slippage);
    }

    /**
    * @notice Allows the owner to add a token to the list of allowed tokens for deposits and holds in the SolsticeVault.
    * @param tokenIn The address of the token to be added.
    * @dev This function can only be called by the owner and when the contract is not paused. It calls the internal `_addAllowedIn` function to perform the addition.
    */
    function addAllowedIn(address tokenIn) public onlyOwner() whenNotPaused() whenInitialized() onlyNotZeroValue(tokenIn) {
        _addAllowedIn(tokenIn);
    }

    /**
    * @notice Pauses the SolsticeVault contract, preventing certain functions from being executed.
    * @dev Only the owner of the contract can pause it.
    */
    function pause() public onlyOwner() {
        _pause();
    }

    /**
    * @notice Unpauses the SolsticeVault contract, allowing execution of previously restricted functions.
    * @dev Only the owner of the contract can unpause it.
    */
    function unpause() public onlyOwner() {
        _unpause();
    }

    /**
    * @notice Calculates the basis points of a given value relative to the total.
    * @param value The value for which the basis points are calculated.
    * @param total The total value against which the basis points are determined.
    * @return The calculated basis points, representing the proportion of the given value relative to the total, expressed in parts per 10,000.
    * @dev This internal function computes the basis points by dividing the given value by the total and then multiplying the result by 10,000.
    */
    function _basis(uint256 value, uint256 total) internal pure returns (uint256) {
        /**
        * Calculates the basis points of a given value relative to the total.
        * This internal function computes the basis points by dividing the given
        * value by the total and then multiplying the result by 10,000.
        */
        return (value * 10000) / total;
    }

    /**
    * @notice Convert a value to its equivalent amount in wei.
    * @param value The value to be converted.
    * @return uint256 The equivalent amount of wei.
    */
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * (10**18);
    }

    /**
    * @notice Calculates the value of a specified token held in the SolsticeVault.
    * @param token The address of the token for which the value is calculated.
    * @return The calculated value of the token based on the mean price obtained from the Finance library, considering the token's balance in the vault.
    * @dev This internal function leverages the Finance library's `meanPrice` function to determine the mean price of the specified token against the denominator. The calculated value is based on the mean price and the balance of the token held within the SolsticeVault.
    */
    function _value(address token) internal view returns (uint256) {
        /**
        * Calculates the value of a specified token held in the SolsticeVault.
        * This internal function leverages the Finance library's `meanPrice` function
        * to determine the mean price of the specified token against the denominator.
        * The calculated value is based on the mean price and the balance of the token
        * held within the SolsticeVault.
        */
        return __Finance.meanPrice(factories(), token, denominator(), _balanceOf(token));
    }
    /** NOTE MODIFIED DURING TESTING NOT YET UPDATED => FLAT SOLSTICE */
    /**
    * @notice Calculates the amount of a token required to match the given value.
    * @param token The address of the token for which to calculate the amount.
    * @param value The target value for which to calculate the amount.
    * @return uint256 Returns the calculated amount of the specified token required to match the given value.
    * @dev Utilizes the Finance library's `meanPrice` function to determine the unit value of the token in terms of the denominator. Divides the target value by the unit value to obtain the required amount.
    */
    function _amount(address token, uint256 value) internal view returns (uint256) {
        /**
        * Calculates the amount of the specified token required to match
        * the given value. Utilizes the Finance library's `meanPrice`
        * function to determine the unit value of the token in terms of
        * the denominator. Divides the target value by the unit value to
        * obtain the required amount.
        */
        uint256 unitValue = __Finance.meanPrice(factories(), token, denominator(), 1);
        uint256 amount;
        if (value != 0 && unitValue != 0) { amount = value / unitValue; }
        return amount;
    }

    /**
    * @notice Calculates the percentage in basis points (100% => 10000) of a specific token's composition within the total holdings of the SolsticeVault.
    * @param token The address of the token for which to calculate the percentage.
    * @return uint256 Returns the percentage in basis points of the specified token's composition within the total balance of the vault.
    * @dev Utilizes the `_value` function to calculate the value of the token and the `balance` function to get the total balance of the SolsticeVault. Calculates the percentage using the `_basis` function.
    */
    function _basisOfHoldings(address token) internal view returns (uint256) {
        /**
        * Calculates the % in basis points ie. 100% => 10000 of the its
        * composition. 5000 means the value of this asset is 50% of the
        * total balance of the vault.
         */
        return _basis(_value(token), balance());
    }

    /**
    * @notice Retrieves the balance of a specific token held by the SolsticeVault.
    * @param token The address of the token for which to retrieve the balance.
    * @return uint256 Returns the balance of the specified token held by the SolsticeVault.
    * @dev Uses the ERC20Metadata interface to query and return the balance of the specified token held by the SolsticeVault.
    */
    function _balanceOf(address token) internal view returns (uint256) {
        /**
        * Retrieves and returns the balance of the specified token held
        * by the SolsticeVault. Uses the ERC20Metadata interface to query
        * the balance of the token.
        */
        return IERC20Metadata(token).balanceOf(address(this));
    }

    /**
    * @notice View function to ensure that a given token is in the set of allowed tokens.
    * @param tokenIn The address of the token to check for permission.
    */
    function _onlyAllowedIn(address tokenIn) internal view {
        require(_allowedIn.contains(tokenIn), "SolsticeVault: !allowedIn");
    }

    /**
    * @notice View function to ensure that the mean price of a given token is not zero.
    * @param tokenIn The address of the token for which to check the mean price.
    */
    function _onlyNotZeroValue(address tokenIn) internal view {
        uint256 value = __Finance.meanPrice(factories(), tokenIn, denominator(), 1);
        require(value != 0, "SolsticeVault: value is zero");
    }

    /**
    * @notice Modifier-like function to ensure that the contract is already initialized.
    */
    function _whenInitialized() internal view {
        require(_initialized, "SolsticeVault: !_initialized");
    }

    /**
    * @notice Modifier-like function to ensure that the contract is not already initialized.
    */
    function _whenNotInitialized() internal view {
        require(!_initialized, "SolsticeVault: _initialized");
    }

    /**
    * @notice Transfers a specified value of a token to a specified account from the SolsticeVault.
    * @param account The address to which the tokens should be transferred.
    * @param tokenOut The address of the token to be transferred.
    * @param valueOut The target value of the token to be transferred.
    * @dev Requires that the target value is not greater than the balance of the specified token. Calculates the amount of the token required to match the target value using the `_amount` function and transfers that amount to the specified account.
    */
    function _transferValue(address account, address tokenOut, uint256 valueOut) internal {
        /**
        * Transfers a specified value of the specified token to the
        * specified account from the SolsticeVault. Requires that the
        * target value is not greater than the balance of the token.
        * Calculates the amount of the token required to match the
        * target value using the `_amount` function and transfers
        * that amount to the specified account.
        */
        require(valueOut <= _balanceOf(tokenOut), "SolsticeVault: insufficient balance");
        uint256 amount = _amount(tokenOut, valueOut);
        IERC20Metadata(tokenOut).transfer(account, amount);
    }

    /**
    * @notice Repays a specified amount in the denominator token to the sender.
    * @param required The amount to be repaid in the denominator token.
    * @return bool Returns true if the repayment is successful; otherwise, returns false.
    * @dev Retrieves the balance and value of the denominator token, and if the value is greater than or equal to the required amount, transfers the entire value in the denominator token to the sender. Returns true if the repayment is successful, otherwise returns false.
    */
    function _repayInDenominator(uint256 required) internal returns (bool) {
        /**
        * Repays a specified amount in the denominator token to the sender.
        * Retrieves the balance and value of the denominator token, and if
        * the value is greater than or equal to the required amount,
        * transfers the entire value in the denominator token to the sender.
        * Returns true if the repayment is successful, otherwise returns false.
        */
        uint256 balance = _balanceOf(denominator());
        uint256 value = _value(denominator());
        if (value >= required) {
            _transferValue(msg.sender, denominator(), value);
            return true;
        }
        return false;
    }

    /**
    * @notice Repays a specified amount in various tokens to the sender proportionally based on their composition within the SolsticeVault.
    * @param required The total amount to be repaid across all tokens.
    * @dev Iterates through all allowed tokens, calculates the value to be repaid for each token based on its percentage composition within the total holdings, and transfers the corresponding amount of each token to the sender.
    */
    function _repayInKind(uint256 required) internal {
        /**
        * Repays a specified amount in various tokens to the sender
        * proportionally based on their composition within the SolsticeVault.
        * Iterates through all allowed tokens, calculates the value to be
        * repaid for each token based on its percentage composition within
        * the total holdings, and transfers the corresponding amount of each
        * token to the sender.
        */
        for (uint256 i = 0; i < _all.length(); i++) {
            uint256 basis = _basisOfHoldings(_all.at(i));
            uint256 valueFrom = (required / 10000) * basis;
            _transferValue(msg.sender, _all.at(i), valueFrom);
        }
    }

    /**
    * @notice Performs checks and actions before accepting a deposit into the SolsticeVault.
    * @param tokenIn The address of the token to be deposited.
    * @param amountIn The amount of the token to be deposited.
    * @dev Ensures that the token being deposited is allowed, calculates its value using the Finance library's `meanPrice` function, and checks for non-zero values (v, s, b) to prevent division by zero. Transfers the specified amount of tokens from the sender to the SolsticeVault.
    */
    function _beforeDeposit(address tokenIn, uint256 amountIn) internal {
        _onlyAllowedIn(tokenIn);
        uint256 v = __Finance.meanPrice(factories(), tokenIn, denominator(), amountIn);
        uint256 s = supply();
        uint256 b = balance();
        require(
            v != 0 &&
            s != 0 &&
            b != 0,
            "SolsticeVault: zero value"
        );
        IERC20Metadata(tokenIn).transferFrom(msg.sender, address(this), amountIn);
    }

    /**
    * @notice Performs actions after a successful deposit into the SolsticeVault.
    * @param tokenIn The address of the token that has been deposited.
    * @param amountIn The amount of the token that has been deposited.
    * @dev Calculates the value (v) of the deposited token using the Finance library's `meanPrice` function. Retrieves the total supply (s) and total balance (b) of the SolsticeVault. Calculates the amount of tokens to mint using the Finance library's `amountToMint` function based on the calculated values. Mints the calculated amount of tokens to the depositor's address.
    */
    function _afterDeposit(address tokenIn, uint256 amountIn) internal {
        uint256 v = __Finance.meanPrice(factories(), tokenIn, denominator(), amountIn);
        uint256 s = supply();
        uint256 b = balance();
        uint256 amountToMint = __Finance.amountToMint(v, s, b);
        _erc20.mint(msg.sender, amountToMint);
    }

    /**
    * @notice Performs checks and actions before processing a withdrawal from the SolsticeVault.
    * @param amountIn The amount of tokens to be withdrawn.
    * @dev Ensures that the withdrawal amount, total supply, and total balance are non-zero. Transfers the specified amount of tokens from the sender to the SolsticeVault and burns an equivalent amount of vault tokens.
    */
    function _beforeWithdraw(uint256 amountIn) internal {
        /**
        * Performs checks and actions before processing a withdrawal from the SolsticeVault.
        * Ensures that the withdrawal amount, total supply, and total balance are non-zero.
        * Transfers the specified amount of tokens from the sender to the SolsticeVault
        * and burns an equivalent amount of vault tokens.
        */
        uint256 a = amountIn;
        uint256 s = supply();
        uint256 b = balance();
        require(
            a != 0 &&
            s != 0 &&
            b != 0,
            "SolsticeVault: zero value"
        );
        _erc20.transferFrom(msg.sender, address(this), amountIn);
        _erc20.burn(amountIn);
    }

    /**
    * @notice Performs actions after a successful withdrawal from the SolsticeVault.
    * @param amountIn The amount of tokens that has been withdrawn.
    * @dev Retrieves the withdrawal amount (a), total supply (s), and total balance (b) of the SolsticeVault. Calculates the value (value) to be repaid based on the withdrawal amount using the Finance library's `amountToSend` function. Attempts to repay the calculated value first in the denominator token using the `_repayInDenominator` function, and if unsuccessful, repays in kind using the `_repayInKind` function. Requires successful repayment and handles deficits by enabling emergency withdrawals for depositors to withdraw the owed value in any token or tokens directly from the vault.
    */
    function _afterWithdraw(uint256 amountIn) internal {
        /**
        * Performs actions after a successful withdrawal from the SolsticeVault.
        * Retrieves the withdrawal amount (a), total supply (s), and total balance (b)
        * of the SolsticeVault. Calculates the value (value) to be repaid based on the
        * withdrawal amount using the Finance library's `amountToSend` function. Attempts
        * to repay the calculated value first in the denominator token using the
        * `_repayInDenominator` function, and if unsuccessful, repays in kind using the
        * `_repayInKind` function. Requires successful repayment and handles deficits
        * by enabling emergency withdrawals for depositors to withdraw the owed value
        * in any token or tokens directly from the vault.
        */
        uint256 a = amountIn;
        uint256 s = supply();
        uint256 b = balance();
        uint256 value = __Finance.amountToSend(a, s, b);
        bool success = _repayInDenominator(value);
        if (!success) { _repayInKind(value); }
        require(success, "SolsticeVault: deficit");

        /**
        * INCASE OF DEFICIT.
        *
        * WARNING: This should never not have enough value
        *          to repay the depositors. The vault should
        *          always have enough value to repay
        *          the depositor. This may happen because one
        *          or more pairs report zero price because
        *          they may not have been found or are just
        *          not correct. It is important that all
        *          allowed in pairs are supported as
        *          TOKEN / DENOMINATOR before adding it
        *          to the allowedIn pair.
        *
        * NOTE Always make sure that allowedIn pairs are
        *      tradeable and price is correctly fetched.
        *
        * NOTE Mitigate this occurence by making sure 
        *      the vault holds a portion of holdings as
        *      denominator to ensure liquidity can be
        *      freely withdrawn.
        *
        * NOTE In the event of a deficit emergency withdrawals
        *      will be enabled allowing depositors to withdraw
        *      the owed value in any token or tokens they want
        *      directly from the vault.
         */
    }

    /**
    * @notice Adds a new Uniswap V2 instance to the list of tracked instances.
    * @dev This internal function is used for configuring the SolsticeVault contract by including information about a Uniswap V2 instance. The provided parameters, including the instance name, factory address, and router address, are used to create a new `UniswapV2` struct, which is then appended to the array of tracked instances.
    * @param name The name of the Uniswap V2 instance.
    * @param factory The address of the Uniswap V2 factory contract associated with the instance.
    * @param router The address of the Uniswap V2 router contract associated with the instance.
    */
    function _pushUniswapV2(string memory name, address factory, address router) internal {
        _uniswapV2s.push(UniswapV2({name: name, factory: factory, router: router}));
    }

    /**
    * @notice Performs checks and actions before executing a token swap on a specified Uniswap V2 router.
    * @dev This internal function ensures that the specified Uniswap V2 router exists, then uses the Finance library to perform token swapping with slippage control. It verifies that the swap operation meets specified slippage requirements.
    * @param router The index of the Uniswap V2 router in the vault's array of routers.
    * @param tokenIn The address of the token to be swapped.
    * @param tokenOut The address of the token to receive from the swap.
    * @param amountIn The amount of the token to be swapped.
    * @param slippage The allowable slippage percentage for the swap operation.
    */
    function _beforeSwap(uint256 router, address tokenIn, address tokenOut, uint256 amountIn, uint256 slippage) internal {
        __Finance.swapTokensSlippage(_uniswapV2s[router].router, factories(), tokenIn, tokenOut, amountIn, slippage, denominator());
    }

    /**
    * @notice Performs actions after a successful token swap.
    * @dev This internal function can be extended to include any necessary actions that need to be taken after a successful token swap. It is left empty for customization based on specific requirements.
    */
    function _afterSwap(uint256 router, address tokenIn, address tokenOut, uint256 amountIn, uint256 slippage) internal {}

    /**
    * @notice Adds a token to the list of allowed tokens for deposits and holds in the SolsticeVault.
    * @param tokenIn The address of the token to be added.
    * @dev This internal function adds the specified token to the list of allowed tokens for deposits and holds in the SolsticeVault. It updates both the `_allowedIn` and `_all` sets, emitting a `TokenAllowedIn` event to signal the addition.
    */
    function _addAllowedIn(address tokenIn) internal {
        _allowedIn.add(tokenIn);
        _all.add(tokenIn);
        emit TokenAllowedIn(tokenIn);
    }
}