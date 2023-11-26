// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";
import "contracts/polygon/diamonds/facets/components/OracleComponent.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurAddressLib.sol";
import "contracts/polygon/libraries/OurUintLib.sol";

library BalanceComponent {
    using RoleComponent for RoleComponent.Role;
    using OracleComponent for OracleComponent.Oracle;
    using OurAddressLib for address;
    using OurUintLib for uint;

    struct Balance {
        EnumerableSet.AddressSet _balance;
        uint _max;
        address _denominator;
        string[] memory _exchanges;
    }

    function balance(Balance storage balance, uint i) internal view returns (string memory name, string memory symbol, uint8 decimals, uint balance) {
        address asset = balance._balance.at(i);
        if (asset.isZero()) {
            /// may also be matic
            return ("Ethereum", "ETH", 18, asset.balance());
        }
        return (asset.name(), asset.symbol(), asset.decimals(), asset.balance());
    }

    function balance(Balance storage balance) internal view returns (address[] memory) {
        return balance._balance.values();
    }

    function balanceLength(Balance storage balance) internal view returns (uint) {
        return balance._balance.length();
    }

    function hasBalance(Balance storage balance, address token) internal view returns (bool) {
        return balance._balance.contains(token);
    }

    function max(Balance storage balance) internal view returns (uint) {
        return balance._max;
    }

    function denominator(Balance storage balance) internal view returns (address) {
        return balance._denominator;
    }

    function exchanges(Balance storage balance, uint i) internal view returns (address) {
        return balance._exchanges[i];
    }

    function exchanges(Balance storage balance) internal view returns (address[] memory) {
        return balance._exchanges;
    }

    function exchangesLength(Balance storage balance) internal view returns (uint) {
        return balance._exchanges.length;
    }

    function sumAverageValue(Balance storage balance, OracleComponent.Oracle storage oracle) internal view returns (uint) {
        uint[] memory amounts;
        amounts = new uint[](balanceLength(balance));
        for (uint i = 0; i < balanceLength(balance); i++) {
            address asset = balance(balance, i);
            amounts[i] = asset.balance();
        }
        return oracle.sumAverageValue(exchanges(balance), balance(balance), amounts, denominator(balance));
    }

    function sumQuoteAverageValue(Balance storage balance, OracleComponent.Oracle storage oracle) internal view returns (uint) {
        uint[] memory amounts;
        amounts = new uint[](balanceLength(balance));
        for (uint i = 0; i < balanceLength(balance); i++) {
            address asset = balance(balance, i);
            amounts[i] = asset.balance();
        }
        return oracle.sumQuoteAverageValue(exchanges(balance), balance(balance), amounts, denominator(balance));
    }

    function addAssetToBalance(Balance storage balance, address asset) internal returns (bool) {
        balance._balance.add(asset);
        return true;
    }

    function removeAssetFromBalance(Balance storage balance, address asset) internal returns (bool) {
        balance._balance.remove(asset);
        return true;
    }

    function setMax(Balance storage balance, uint value) internal returns (bool) {
        balance._max = value;
        return true;
    }

    function setDenominator(Balance storage balance, address denominator) internal returns (bool) {
        balance._denominator = denominator;
        return true;
    }

    function deposit(Safe storage safe, RoleComponent.Role storage role, address tokenIn, uint amountIn) internal {
        role.tryAuthenticate();
        if (tokenIn.isZero() && amountIn.isZero()) {
            /// address zero in the context of types indicates ether
            if (address(this).balance == 0) {
                safe._types.add(address(0));
                safe._maxTypes ++;
            }
            /// value deposit
        } else {
            require(tokenIn.isContract(), "BalanceComponent: token in is not contract");
            tokenIn.pull(amountIn);
            /// check if to add token as new type
            if (tokenIn.balance() == 0) {
                
            }
        }
    }
}