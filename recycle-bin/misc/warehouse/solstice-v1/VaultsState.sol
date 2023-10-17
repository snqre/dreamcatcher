// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/mirai/solstice-v1/__Vaults.sol";
import "contracts/polygon/templates/mirai/solstice-v1/VaultsLogic.sol";
import "contracts/polygon/templates/mirai/solstice-v1/Token.sol";

interface IVaultsState {
    function setLogic(address logic_) external;
    function set(
        uint id,
        Token token,
        EnumerableSet.AddressSet contracts,
        EnumerableSet.UintSet amounts
    ) external;

    function get() external view returns (
        Token,
        EnumerableSet.AddressSet,
        EnumerableSet.UintSet
    );

    function getLength() external view returns (uint);
}

contract VaultsState is IVaultsState { /// vault database
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Vault {
        Token token;
        EnumerableSet.AddressSet contracts;
        EnumerableSet.UintSet amounts;
    }

    address public logic;
    Vault[] private vaults;

    function setLogic(address logic_)
        public {
        logic = logic_;
    }

    function push()
        public {
        vaults.push();
    }
    
    function set(
        uint id,
        Token token, 
        EnumerableSet.AddressSet contracts,
        EnumerableSet.UintSet amounts
        ) public {
        Vault storage vault = vaults[id];
        vault.token = token;
        vault.contracts = contracts;
        vault.amounts = amounts;
    }

    function get(uint id)
        public view
        returns (
            Token,
            EnumerableSet.AddressSet,
            EnumerableSet.UintSet
        ) {
        Vault storage vault = vaults[id];
        return (
            vault.token,
            vault.contracts,
            vault.amounts
        );
    }

    function getLength()
        public view
        returns (uint) {
        return vaults.length;
    }
}