// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/slots/.components/TokenComponent.sol";
import "contracts/polygon/slots/.components/OracleComponent.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/OurAddressLib.sol":

library DepositComponent {
    using TokenComponent for TokenComponent.Token;
    using OracleComponent for OracleComponent.Oracle;
    using EnumerableSet for EnumerableSet.AddressSet;
    using OurAddressLib for address;

    event Deposit(address account, address tokenIn, uint amountIn);
    event DepositAllowed();
    event DepositDisallowed();
    event DepositAllowanceEnabled();
    event DepositAllowanceDisabled();
    event DepositAllowanceSet(uint oldAllowance, uint newAllowance);
    event DepositMinSizeEnabled();
    event DepositMinSizeDisabled();
    event DepositMinSizeSet(uint oldMinSize, uint newMinSize);
    event DepositMaxSizeEnabled();
    event DepositMaxSizeDisabled();
    event DepositMaxSizeSet(uint oldMaxSize, uint newMaxSize);
    event DepositAddedToWhitelist(address account);
    event DepositRemovedFromWhitelist(address account);
    event DepositAddedToBlacklist(address account);
    event DepositRemovedFromBlacklist(address account);
    event DepositWhitelistEnabled();
    event DepositWhitelistDisabled();
    event DepositBlacklistEnabled();
    event DepositBlacklistDisabled();

    struct Deposit {
        uint _balance;
        mapping(address => uint) _balances;
        bool _allowed;
        bool _hasAllowance;
        bool _hasMinSize;
        bool _hasMaxSize;
        bool _hasWhitelist;
        bool _hasBlacklist;
        uint _allowance;
        uint _minSize;
        uint _maxSize;
        EnumerableSet.AddressSet _whitelist;
        EnumerableSet.AddressSet _blacklist;
    }

    function balance(Deposit storage deposit) internal view returns (uint) {
        /// 10**18
        return deposit._balance;
    }

    function balances(Deposit storage deposit, address token) internal view returns (uint) {
        /// return as 10**18
        return deposit._balances[token];
    }

    function allowed(Deposit storage deposit) internal view returns (bool) {
        return deposit.__allowed;
    }

    function hasAllowance(Deposit storage deposit) internal view returns (bool) {
        return deposit._hasAllowance;
    }

    function hasMinSize(Deposit storage deposit) internal view returns (bool) {
        return deposit._hasMinSize;
    }

    function hasMaxSize(Deposit storage deposit) internal view returns (bool) {
        return deposit._hasMaxSize;
    }

    function hasWhitelist(Deposit storage deposit) internal view returns (bool) {
        return deposit._hasWhitelist;
    }

    function hasBlacklist(Deposit storage deposit) internal view returns (bool) {
        return deposit._hasBlacklist;
    }

    function allowance(Deposit storage deposit) internal view returns (uint) {
        return deposit._allowance;
    }

    function minSize(Deposit storage deposit) internal view returns (uint) {
        return deposit._minSize;
    }

    function maxSize(Deposit storage deposit) internal view returns (uint) {
        return deposit._maxSize;
    }

    function whitelist(Deposit storage deposit, uint i) internal view returns (address) {
        return deposit._whitelist.at(i);
    }

    function whitelist(Deposit storage deposit) internal view returns (address[] memory) {
        return deposit._whitelist.values();
    }

    function whitelistLength(Deposit storage deposit) internal view returns (uint) {
        return deposit._whitelist.length();
    }

    function whitelistContains(Deposit storage deposit, address account) internal view returns (bool) {
        return deposit._whitelist.contains(account);
    }

    function blacklist(Deposit storage deposit, uint i) internal view returns (address) {
        return deposit._blacklist.at(i);
    }

    function blacklist(Deposit storage deposit) internal view returns (address[] memory) {
        return deposit._blacklist.values();
    }

    function blacklistLength(Deposit storage deposit) internal view returns (uint) {
        return deposit._blacklist.length();
    }

    function blacklistContains(Deposit storage deposit, address account) internal view returns (bool) {
        return deposit._blacklist.contains(account);
    }

    function deposit(Deposit storage deposit, OracleComponent.Oracle storage oracle, address tokenIn, uint amountIn) internal returns (bool) {
        _deposit(deposit, oracle, tokenIn, amountIn);
        emit Deposit(msg.sender, tokenIn, amountIn);
        return true;
    }

    function allow(Deposit storage deposit) internal returns (bool) {
        _allow(deposit);
        emit DepositAllowed();
        return true;
    }

    function disallow(Deposit storage deposit) internal returns (bool) {
        _disallow(deposit);
        emit DepositDisallowed();
        return true;
    }

    function enableAllowance(Deposit storage deposit) internal returns (bool) {
        _enableAllowance(deposit);
        emit DepositAllowanceEnabled();
        return true;
    }

    function disableAllowance(Deposit storage deposit) internal returns (bool) {
        _disableAllowance(deposit);
        emit DepositAllowanceDisabled();
        return true;
    }

    function setAllowance(Deposit storage deposit, uint allowance) internal returns (bool) {
        uint oldAllowance = allowance(deposit);
        _setAllowance(deposit, allowance);
        emit DepositAllowanceSet(oldAllowance, allowance);
        return true;
    }

    function enableMinSize(Deposit storage deposit) internal returns (bool) {
        _enableAllowance(deposit);
        emit DepositMinSizeEnabled();
        return true;
    }

    function disableMinSize(Deposit storage deposit) internal returns (bool) {
        _disableAllowance(deposit);
        emit DepositMinSizeDisabled();
        return true;
    }

    function setMinSize(Deposit storage deposit, uint minSize) internal returns (bool) {
        uint oldMinSize = minSize(deposit);
        _setMinSize(deposit, minSize);
        emit DepositMinSizeSet(oldMinSize, minSize);
        return true;
    }

    function enableMaxSize(Deposit storage deposit) internal returns (bool) {
        _enableMaxSize(deposit);
        emit DepositMaxSizeEnabled();
        return true;
    }

    function disableMaxSize(Deposit storage deposit) internal returns (bool) {
        _disableMaxSize(deposit);
        emit DepositMaxSizeDisabled();
        return true;
    }

    function setMaxSize(Deposit storage deposit, uint maxSize) internal returns (bool) {
        uint oldMaxSize = maxSize(deposit);
        _setMaxSize(deposit, maxSize);
        emit DepositMaxSizeSet(oldMaxSize, maxSize);
        return true;
    }

    function enableWhitelist(Deposit storage deposit) internal returns (bool) {
        _enableWhitelist(deposit);
        emit DepositWhitelistEnabled();
        return true;
    }

    function disableWhitelist(Deposit storage deposit) internal returns (bool) {
        _disableWhitelist(deposit);
        emit DepositWhitelistDisabled();
        return true;
    }

    function addToWhitelist(Deposit storage deposit, address account) internal returns (bool) {
        _addToWhitelist(deposit, account);
        emit DepositAddedToWhitelist(account);
        return true;
    }

    function removeFromWhitelist(Deposit storage deposit, address account) internal returns (bool) {
        _removeFromWhitelist(deposit, account);
        emit DepositRemovedFromWhitelist(account);
        return true;
    }

    function enableBlacklist(Deposit storage deposit) internal returns (bool) {
        _enableBlacklist(deposit);
        emit DepositBlacklistEnabled();
        return true;
    }

    function disableBlacklist(Deposit storage deposit) internal returns (bool) {
        _disableBlacklist(deposit);
        emit DepositBlacklistDisabled();
        return true;
    }

    function addToBlacklist(Deposit storage deposit, address account) internal returns (bool) {
        _addToBlacklist(deposit, account);
        emit DepositAddedToBlacklist(account);
        return true;
    }

    function removeFromBlacklist(Deposit storage deposit, address account) internal returns (bool) {
        _removeFromBlacklist(deposit, account);
        emit DepositRemovedFromBlacklist(account);
        return true;
    }

    /// amountIn as native decimals of tokenIn
    function _deposit(Deposit storage deposit, OracleComponent.Oracle storage oracle, address tokenIn, uint amountIn) private returns (bool) {
        require(allowed(deposit), "DepositComponent: not allowed");
        if (hasAllowance(deposit) || hasMinSize(deposit) || hasMaxSize(deposit)) {
            /// checks that require oracle
            require(oracle.denominator() != address(0), "DepositComponent: denominator is zero");
            uint valueIn = oracle.quoteAverageValue(tokenIn, oracle.denominator(), amountIn);
            if (hasAllowance(deposit)) {
                unchecked {
                    /// overflow means that the allowance is "negative" and has been exceeded
                    require(allowance(deposit) - amountIn == 0, "DepositComponent: allowance exceeded");
                    deposit._allowance -= valueIn;
                }
            }
            if (hasMinSize(deposit)) {
                require(valueIn >= minSize(deposit), "DepositComponent: valueIn too small");
            }
            if (hasMaxSize(deposit)) {
                require(valueIn <= maxSize(deposit), "DepositComponent: valueIn too large");
            }
        }
        if (hasWhitelist(deposit)) {
            /// whitelist allows only whitelisted accounts to deposit
            require(whitelistContains(msg.sender), "DepositComponent: you are not on the whitelist");
        }
        if (hasBlacklist(deposit)) {
            /// blacklist rejects deposit from blacklisted accounts
            require(!blacklistContains(msg.sender), "DepositComponent: you are on the blacklist");
        }
        /// register amount
        deposit._balances[tokenIn] = amountIn.computeAsEtherValue(tokenIn.decimals());
        tokenIn.safePull(amountIn);
        return true;
    }

    function _allow(Deposit storage deposit) private returns (bool) {
        deposit._allowed = true;
        return true;
    }

    function _disallow(Deposit storage deposit) private returns (bool) {
        deposit._allowed = false;
        return true;
    }

    function _enableAllowance(Deposit storage deposit) private returns (bool) {
        deposit._hasAllowance = true;
        return true;
    }

    function _disableAllowance(Deposit storage deposit) private returns (bool) {
        deposit._hasAllowance = false;
        return true;
    }

    function _setAllowance(Deposit storage deposit, uint allowance) private returns (bool) {
        deposit._allowance = allowance;
        return true;
    }

    function _enableMinSize(Deposit storage deposit) private returns (bool) {
        deposit._hasMinSize = true;
        return true;
    }

    function _disableMinSize(Deposit storage deposit) private returns (bool) {
        deposit._hasMaxSize = false;
        return true;
    }

    function _setMinSize(Deposit storage deposit, uint minSize) private returns (bool) {
        deposit._minSize = minSize;
        return true;
    }

    function _enableMaxSize(Deposit storage deposit) private returns (bool) {
        deposit._hasMaxSize = true;
        return true;
    }

    function _disableMaxSize(Deposit storage deposit) private returns (bool) {
        deposit._hasMaxSize = false;
        return true;
    }

    function _setMaxSize(Deposit storage deposit, uint maxSize) private returns (bool) {
        deposit._maxSize = maxSize;
        return true;
    }

    function _enableWhitelist(Deposit storage deposit) private returns (bool) {
        deposit._hasWhitelist = true;
        return true;
    }

    function _disableWhitelist(Deposit storage deposit) private returns (bool) {
        deposit._hasWhitelist = false;
        return false;
    }

    function _addToWhitelist(Deposit storage deposit, address account) private returns (bool) {
        deposit._whitelist.add(account);
        return true;
    }

    function _removeFromWhitelist(Deposit storage deposit, address account) private returns (bool) {
        deposit._whitelist.remove(account);
        return true;
    }

    function _enableBlacklist(Deposit storage deposit) private returns (bool) {
        deposit._hasBlacklist = true;
        return true;
    }

    function _disableBlacklist(Deposit storage deposit) private returns (bool) {
        deposit._hasBlacklist = false;
        return true;
    }

    function _addToBlacklist(Deposit storage deposit, address account) private returns (bool) {
        deposit._blacklist.add(account);
        return true;
    }

    function _removeFromBlacklist(Deposit storage deposit, address account) private returns (bool) {
        deposit._blacklist.remove(account);
        return true;
    }
}