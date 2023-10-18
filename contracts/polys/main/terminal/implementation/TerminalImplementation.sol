// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/DefaultImplementation.sol";
import "contracts/polygon/abstract/access-control/Role.sol";
import "contracts/polygon/abstract/security/Pausable.sol";
import "contracts/polygon/abstract/utils/LowLevelCall.sol";

contract TerminalImplementation is DefaultImplementation, Role, LowLevelCall {

    /**
    * @dev Initializes the contract. This function is called only once during deployment.
    * It sets the initial implementation and transfers ownership to the deployer.
    */
    function initialize() public virtual override {
        super.initialize();
    }

    /**
    * @dev Upgrades the contract's implementation. Only accessible by an address with the UPGRADER_ROLE
    * and when the contract is paused.
    * @param implementation The address of the new implementation.
    */
    function upgrade(address implementation) public virtual override {
        _whenPaused();
        requireRole(roleKey(hash("UPGRADER_ROLE")), msg.sender);
        _upgrade(implementation);
    }

    /**
    * @dev Pauses the contract. Only accessible by an address with the PAUSER_ROLE.
    */
    function pause() public virtual {
        requireRole(roleKey(hash("PAUSER_ROLE")), msg.sender);
        _pause();
    }

    /**
    * @dev Unpauses the contract. Only accessible by an address with the UNPAUSE_ROLE.
    */
    function unpause() public virtual {
        requireRole(roleKey(hash("UNPAUSE_ROLE")), msg.sender);
        _unpause();
    }

    /**
    * @dev Initiates a low-level call to the specified target address with the provided data.
    * Only accessible by an address with the LOW_LEVEL_CALLER_ROLE.
    */
    function lowLeveCall(address target, bytes memory data) public virtual returns (bytes memory) {

        /**
        * abi.encodeWithSelector =>
        * bytes4(keccak256("")),
        * , , , =? args
         */
        requireRole(roleKey(hash("LOW_LEVEL_CALLER_ROLE")), msg.sender);
        return _lowLevelCall(target, data);
    }

    /**
    * @dev Initializes the contract by calling the initialization functions of DefaultImplementation and Role.
    * Grants the default admin role to the contract and ensures that the contract is unpaused.
    */
    function _initialize() internal virtual override(Ownable, Role) {
        Ownable._initialize();
        Role._initialize();
        _grantRole(roleKey(defaultAdminRoleKey()), address(this));
        _unpause();
    }
}