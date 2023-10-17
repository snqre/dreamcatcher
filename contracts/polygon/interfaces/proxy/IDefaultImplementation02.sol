// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IBase.sol";
import "contracts/polygon/interfaces/access-control/IOwnable.sol";
import "contracts/polygon/interfaces/utils/IInitializable.sol";
import "contracts/polygon/interfaces/security/IPausable.sol";

interface IDefaultImplementation02 is IBase, IOwnable, IPausable, IInitializable {

    /**
    * @dev Initializes the contract with the specified terminal address.
    * It sets the terminal address using the `_initialize` internal function.
    * @param terminal The address of the terminal contract.
    */
    function initialize(address terminal) external;

    /**
    * @dev Upgrades the contract to a new implementation.
    * It checks that the sender has the default admin role using the `_onlyDefaultAdminRole` modifier.
    * It then upgrades the contract using the `_upgrade` internal function with the provided implementation address.
    * @param implementation The address of the new implementation contract.
    */
    function upgrade(address implementation) external;

    /**
    * @dev Pauses the contract by calling the internal `_pause` function.
    * It checks that the sender has the default admin role using the `_onlyDefaultAdminRole` modifier before pausing.
    */
    function pause() external;

    /**
    * @dev Unpauses the contract by calling the internal `_unpause` function.
    * It checks that the sender has the default admin role using the `_onlyDefaultAdminRole` modifier before unpausing.
    */
    function unpause() external;
}