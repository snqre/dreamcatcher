// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/Shell.sol';
import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';

/**
* @dev This implementation is directly based on the OpenZeppelin ERC20
*      implementation. The changes made are so that no variables are
*      being declared, instead it is using the node's storage.
*
* @dev This can be directly incorporated with any other shell
*      implementation, therefore, making it easier to build
*      tokenized vaults and controlling the tokens directly from
*      the tokenized vault.
*
* NOTE The only functions the owner can specially call are
*      setName and setSymbol which can only be done once. This is
*      checked. If the name or symbol storage location at dString is
*      an empty string, then it will allow the owner to set these
*      fields. If the dString storage is not empty, then it will not
*      allow the owner to set the respective fields. This is intended
*      to be set once during deployment by a contract or factory.
*      It is important to realize that during an upgrade any of these
*      checks can change, therefore, it is important to check
*      the new implementations heavily before upgrading.
*
* WARNING: The shell implementation comes with the owner's privilage to
*          upgrade the contract and, set the name, and symbol on 
*          deployment.
*
* ATTACK SURFACE
* | transfer
* | transferFrom
* | increaseAllowance
* | decreaseAllowance
* | approve
* | setName
* | setSymbol
 */
contract slToken is Shell, Context, IERC20Metadata {

    /** Name. */

    /**
     * @dev Get the name of the token.
     * @return The name of the token.
     */
    function name() external view virtual returns (string memory) {
        return _name();
    }

    /**
     * @dev Set the name of the token. Only callable by the owner.
     * @param newName The new name for the token.
     */
    function setName(string memory newName) external virtual {
        _onlyOwner();
        _setName(newName);
    }

    /**
     * @dev Internal function to retrieve the token name from storage.
     * @return The current name of the token.
     */
    function _name() internal view virtual returns (string memory) {
        return dString[NAME()];
    }

    /**
     * @dev Internal function to set the token name in storage.
     * @param newName The new name to be set.
     */
    function _setName(string memory newName) internal virtual {
        require(__isEmptyString(newName), 'slToken: cannot set token name again');
        dString[NAME()] = newName;
    }

    /** @dev dString storage */
    function NAME() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode('NAME'));
    }

    /** Symbol. */

    /**
     * @dev Get the symbol of the token.
     * @return The symbol of the token.
     */
    function symbol() external view virtual returns (string memory) {
        return _symbol();
    }

    /**
     * @dev Set the symbol of the token. Only callable by the owner.
     * @param newSymbol The new symbol for the token.
     */
    function setSymbol(string memory newSymbol) external virtual {
        _onlyOwner();
        _setSymbol(newSymbol);
    }

    /**
     * @dev Internal function to retrieve the token symbol from storage.
     * @return The current symbol of the token.
     */
    function _symbol() internal view virtual returns (string memory) {
        return dString[SYMBOL()];
    }

    /**
     * @dev Internal function to set the token symbol in storage.
     * @param newSymbol The new symbol to be set.
     */
    function _setSymbol(string memory newSymbol) internal virtual {
        require(__isEmptyString(newSymbol), 'slToken: cannot set token symbol again');
        dString[SYMBOL()] = newSymbol;
    }

    /** @dev dString storage */
    function SYMBOL() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode('SYMBOL'));
    }

    /** String matching. */

    /**
     * @dev Check if a string is empty.
     * @param aString The string to check.
     * @return True if the string is empty, false otherwise.
     */
    function __isEmptyString(string memory aString) private returns (bool) {
        string memory emptyString;
        return keccak256(abi.encode(aString)) == keccak256(abi.encode(emptyString));
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() external view virtual returns (uint8) {
        return _decimals();
    }

    /**
    * @dev Returns the number of decimals used to get its user representation.
    * In this case, the default is 18.
    */
    function _decimals() internal view virtual returns (uint8) {
        return 18;
    }

    /** Approve. */

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint amount) external virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint addedValue) external virtual returns (bool) {
        _increaseAllowance(spender, addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint subtractedValue) external virtual returns (bool) {
        _decreaseAllowance(spender, subtractedValue);
        return true;
    }

    /**
    * @dev Internal function to increase the allowance granted to `spender` by the caller.
    * 
    * Emits an {Approval} event indicating the updated allowance.
    * 
    * Requirements:
    * - `owner_` must have sufficient balance to increase the allowance.
    * - `spender` must not be the zero address.
    * 
    * @param spender The address which will spend the funds.
    * @param addedValue The amount of increase in allowance.
    */
    function _increaseAllowance(address spender, uint addedValue) internal virtual {
        _approve(_msgSender(), spender, _allowance(_msgSender(), spender) + addedValue);
    }

    /**
    * @dev Internal function to decrease the allowance granted to `spender` by the caller.
    * 
    * Emits an {Approval} event indicating the updated allowance.
    * 
    * Requirements:
    * - `owner_` must have sufficient allowance to decrease.
    * - `spender` must not be the zero address.
    * - Decreased allowance must not go below zero.
    * 
    * @param spender The address which will spend the funds.
    * @param subtractedValue The amount of decrease in allowance.
    * 
    * Emits an {Approval} event indicating the updated allowance.
    * 
    * Requirements:
    * - `owner_` must have sufficient balance to increase the allowance.
    * - `spender` must not be the zero address.
    */
    function _decreaseAllowance(address spender, uint subtractedValue) internal virtual {
        uint currentAllowance = _allowance(_msgSender(), spender);
        require(currentAllowance >= subtractedValue, 'slToken: decreased allowance below zero');
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
    }

    /**
     * @dev Updates `master` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner_, address spender, uint amount) internal virtual {
        uint currentAllowance = _allowance(owner_, spender);
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, 'slToken: insufficient allowance');
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }

   /**
     * @dev Sets `amount` as the allowance of `spender` over the `master` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `master` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint amount) internal virtual {
        require(owner_ != address(0), 'slToken: approve from the zero address');
        require(spender != address(0), 'slToken: approve to the zero address');
        dUint[ALLOWANCES(owner_, spender)] = amount;
        emit Approval(owner_, spender, amount);
    }

    /** Allowance. */

    /**
    * @dev Returns the remaining allowance of tokens that `spender` is allowed
    * to spend on behalf of `owner_`.
    * 
    * This is the current allowance as set by the {approve} function.
    * 
    * @param owner_ The address of the account that owns the tokens.
    * @param spender The address which will spend the funds.
    * @return The remaining allowance for `spender` on `owner_'s` tokens.
    */
    function allowance(address owner_, address spender) external view virtual returns (uint) {
        return _allowance(owner_, spender);
    }

    /**
    * @dev Internal function to get the remaining allowance of tokens that `spender` is allowed
    * to spend on behalf of `owner_`.
    * 
    * This is the current allowance as stored in the contract state.
    * 
    * @param owner_ The address of the account that owns the tokens.
    * @param spender The address which will spend the funds.
    * @return The remaining allowance for `spender` on `owner_'s` tokens.
    */
    function _allowance(address owner_, address spender) internal view virtual returns (uint) {
        return dUint[ALLOWANCES(owner_, spender)];
    }

    /** @dev dUint storage */
    function ALLOWANCES(address owner_, address spender) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode('ALLOWANCES', owner_, spender));
    }

    /** Mint. */

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), 'slToken: mint to the zero address');
        _beforeTokenTransfer(address(0), account, amount);
        dUint[TOTALSUPPLY()] += amount;
        unchecked {
            dUint[BALANCES(account)] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    /** Burn. */

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), 'slToken: burn from the zero address');
        _beforeTokenTransfer(account, address(0), amount);
        uint accountBalance = dUint[BALANCES(account)];
        require(accountBalance >= amount, 'slToken: burn amount exceeds balance');
        unchecked {
            dUint[BALANCES(account)] = accountBalance - amount;
            dUint[TOTALSUPPLY()] -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    /** Supply. */

    /**
    * @dev Returns the total supply of the token.
    * 
    * @return The total supply of the token.
    */
    function totalSupply() external view virtual returns (uint) {
        return _totalSupply();
    }

    /**
    * @dev Internal function to get the total supply of the token.
    * 
    * This is the current total supply as stored in the contract state.
    * 
    * @return The total supply of the token.
    */
    function _totalSupply() internal view virtual returns (uint) {
        return dUint[TOTALSUPPLY()];
    }

    /** dUint storage */
    function TOTALSUPPLY() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode('TOTALSUPPLY'));
    }

    /** Transfer */

    /**
    * @dev Transfers `amount` tokens from the `from` address to the `to` address,
    * on behalf of the caller.
    * 
    * Emits a {Transfer} event indicating the transfer.
    * 
    * Requirements:
    * - Caller must have sufficient allowance to transfer the specified amount on behalf of `from`.
    * - `from` and `to` addresses must not be the zero address.
    * 
    * @param from The address from which the tokens are transferred.
    * @param to The address to which the tokens are transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful.
    */
    function transferFrom(address from, address to, uint amount) external virtual returns (bool) {
        _transferFrom(from, to, amount);
        return true;
    }

    /**
    * @dev Transfers `amount` tokens from the caller's account to the specified `to` address.
    * 
    * Emits a {Transfer} event indicating the transfer.
    * 
    * Requirements:
    * - Caller must have sufficient balance to transfer the specified amount.
    * - The `to` address must not be the zero address.
    * 
    * @param to The address to which the tokens are transferred.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean indicating whether the transfer was successful.
    */
    function transfer(address to, uint amount) external virtual returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    /**
    * @dev Internal function to transfer `amount` tokens from the `from` address to the `to` address,
    * on behalf of the `_msgSender()`.
    * 
    * This function first ensures that the `_msgSender()` has sufficient allowance to spend on behalf of `from`.
    * Then, it calls the internal `_transfer` function to perform the actual transfer.
    * 
    * Requirements:
    * - `_msgSender()` must have sufficient allowance to spend on behalf of `from`.
    * 
    * @param from The address from which the tokens are transferred.
    * @param to The address to which the tokens are transferred.
    * @param amount The amount of tokens to be transferred.
    */
    function _transferFrom(address from, address to, uint amount) internal virtual {
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);
    }

    /**
    * @dev Internal function to transfer `amount` tokens from the `from` address to the `to` address.
    * 
    * Emits a {Transfer} event indicating the transfer.
    * 
    * Requirements:
    * - `from` and `to` addresses must not be the zero address.
    * - `from` must have sufficient balance to transfer the specified amount.
    * 
    * @param from The address from which the tokens are transferred.
    * @param to The address to which the tokens are transferred.
    * @param amount The amount of tokens to be transferred.
    */
    function _transfer(address from, address to, uint amount) internal virtual {
        require(from != address(0), 'slToken: transfer from the zero address');
        require(to != address(0), 'slToken: transfer to the zero address');
        _beforeTokenTransfer(from, to, amount);
        uint fromBalance = _balanceOf(from);
        require(fromBalance >= amount, 'slToken: transfer amount exceeds balance');
        unchecked {
            dUint[BALANCES(from)] = fromBalance - amount;
            dUint[BALANCES(to)] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint amount) internal virtual {}

    /** Balance. */

    /**
    * @dev Returns the balance of the specified account.
    * 
    * @param account The address for which to retrieve the balance.
    * @return The balance of the specified account.
    */
    function balanceOf(address account) external view virtual returns (uint) {
        return _balanceOf(account);
    }

    /**
    * @dev Internal function to get the balance of the specified account.
    * 
    * This is the current balance as stored in the contract state.
    * 
    * @param account The address for which to retrieve the balance.
    * @return The balance of the specified account.
    */
    function _balanceOf(address account) internal view virtual returns (uint) {
        return dUint[BALANCES(account)];
    }

    /** dUint storage */
    function BALANCES(address account) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode('BALANCES', account));
    }
}