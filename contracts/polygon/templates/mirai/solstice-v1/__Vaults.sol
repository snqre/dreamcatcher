// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/mirai/solstice-v1/Token.sol";

library __Vaults {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Vault {
        Token token;
        EnumerableSet.AddressSet contracts;
        EnumerableSet.UintSet amounts;
        uint sumValue;
    }

    function convertToWei(uint value)
        public pure
        returns (uint) {
        return value * (10**18);
    }

    /// send an amount of value to receive shares in return
    function amountToMint(uint value, uint supply, uint balance)
        public pure
        returns (uint) {
        require(value >= convertToWei(1), "__Vaults: value cannot be zero");
        require(supply >= convertToWei(1), "__Vaults: supply cannot be zero");
        require(balance >= convertToWei(1), "__Vaults: balance cannot be zero");
        return (value * supply) / balance;
    }

    /// burn an amount of shares to receive value in return
    function amountToSend(uint amount, uint supply, uint balance)
        public pure
        returns (uint) {
        require(amount >= convertToWei(1), "__Vaults: value cannot be zero");
        require(supply >= convertToWei(1), "__Vaults: supply cannot be zero");
        require(balance >= convertToWei(1), "__Vaults: balance cannot be zero");
        return (amount * balance) / supply;
    }

    function contribute(Vault[] storage vaults, address token, uint id, uint amount)
        public {
            bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
            require(success, "__Vaults: unsuccessful > IERC20(token).transferFrom(msg.sender, address(this), amount)");
            Vault storage vault = vaults[id];
            uint amountToMint_ = amountToMint(amount, vault.supply, vault.balance);
            
        }
}