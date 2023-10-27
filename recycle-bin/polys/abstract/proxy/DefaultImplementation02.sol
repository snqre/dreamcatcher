// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/Base.sol";
import "contracts/polygon/abstract/access-control/Ownable02.sol";
import "contracts/polygon/abstract/utils/Initializable.sol";
import "contracts/polygon/abstract/security/Pausable.sol";

abstract contract DefaultImplementation02 is Base, Ownable02, Pausable, Initializable {

    /**
    * @dev Initializes the contract with the specified terminal address.
    * It sets the terminal address using the `_initialize` internal function.
    * @param terminal The address of the terminal contract.
    */
    function initialize(address terminal) public virtual {
        _initialize(terminal);
    }

    /**
    * @dev Upgrades the contract to a new implementation.
    * It checks that the sender has the default admin role using the `_onlyDefaultAdminRole` modifier.
    * It then upgrades the contract using the `_upgrade` internal function with the provided implementation address.
    * @param implementation The address of the new implementation contract.
    */
    function upgrade(address implementation) public virtual {
        _onlyDefaultAdminRole();
        _upgrade(implementation);
    }

    /**
    * @dev Pauses the contract by calling the internal `_pause` function.
    * It checks that the sender has the default admin role using the `_onlyDefaultAdminRole` modifier before pausing.
    */
    function pause() public virtual {
        _onlyDefaultAdminRole();
        _pause();
    }

    /**
    * @dev Unpauses the contract by calling the internal `_unpause` function.
    * It checks that the sender has the default admin role using the `_onlyDefaultAdminRole` modifier before unpausing.
    */
    function unpause() public virtual {
        _onlyDefaultAdminRole();
        _unpause();
    }

    /**
    * @dev Initializes the contract by calling the internal `_initialize` function of the parent contracts.
    * It sets the terminal address using the provided parameter and initializes the contract with the Initializable library.
    * 
    * @param terminal The address of the terminal to be set.
    */
    function _initialize(address terminal) internal virtual override {
        super._initialize(terminal);
        Initializable._initialize();
    }
}