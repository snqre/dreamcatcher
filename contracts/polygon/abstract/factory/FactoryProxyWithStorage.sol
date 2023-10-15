// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/ProxyWithStorage.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract FactoryProxyWithStorage is ProxyWithStorage, Context {

    /**
    * @notice Private array to store deployed instances of the ProxyWithStorage contract.
    * @dev This array holds references to the deployed instances of the ProxyWithStorage contract.
    */
    ProxyWithStorage[] private _deployed;

    

/**
 * @notice Retrieves the address of a deployed instance at the specified index.
 * @dev Returns the address of the deployed instance based on the provided deployedId.
 * @param deployedId The index of the deployed instance in the `_deployed` array.
 * @return address The address of the deployed instance at the specified index.
 */
    function deployed(uint deployedId) external view virtual returns (address) {
        return address(_deployed[deployedId]);
    }

/**
 * @notice Deploys a new instance of the ProxyWithStorage contract with the specified implementation.
 * @dev Initiates the deployment of a new instance of the ProxyWithStorage contract using the provided implementation.
 * @param implementation The address of the implementation contract to be used for the new deployment.
 */
    function deploy(address implementation) external virtual {
        _deploy(implementation);
    }

    function _currentId() internal view virtual {
        return _deployed.length - 1;
    }

    function _deploy(address implementation) internal virtual {
        _deployed.push(new ProxyWithStorage());
        _deployed[_currentId()].initialize(implementation);
        _deployed[_currentId()].transferOwnership(_msgSender());
    }
}