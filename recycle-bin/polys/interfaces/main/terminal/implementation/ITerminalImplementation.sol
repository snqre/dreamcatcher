// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/IDefaultImplementation.sol";
import "contracts/polygon/interfaces/access-control/IRole.sol";
import "contracts/polygon/interfaces/security/IPausable.sol";
import "contracts/polygon/interfaces/utils/ILowLevelCall.sol";

interface ITerminalImplementation is IDefaultImplementation, IRole, ILowLevelCall {

    /**
    * @dev Initializes the contract. This function is called only once during deployment.
    * It sets the initial implementation and transfers ownership to the deployer.
    */
    function initialize() external;

    /**
    * @dev Upgrades the contract's implementation. Only accessible by an address with the UPGRADER_ROLE
    * and when the contract is paused.
    * @param implementation The address of the new implementation.
    */
    function upgrade(address implementation) external;

    /**
    * @dev Pauses the contract. Only accessible by an address with the PAUSER_ROLE.
    */
    function pause() external;

    /**
    * @dev Unpauses the contract. Only accessible by an address with the UNPAUSE_ROLE.
    */
    function unpause() external;

    /**
    * @dev Initiates a low-level call to the specified target address with the provided data.
    * Only accessible by an address with the LOW_LEVEL_CALLER_ROLE.
    */
    function lowLevelCall(address target, bytes memory data) external returns (bytes memory);
}