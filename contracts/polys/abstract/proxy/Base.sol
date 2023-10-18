// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* NOTE: https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies
*
* implementationKey => address
* implementationTimelineKey => addressArray
* initialImplementationHasBeenSetKey => address
 */
contract Base is Storage, Proxy {

    /**
    * @dev Emitted when the contract is upgraded to a new implementation.
    * 
    * @param implementation The address of the new implementation contract.
    */
    event Upgraded(address indexed implementation);

    /**
    * @dev Returns the key used to store the address of the current implementation contract.
    */
    function implementationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    /**
    * @dev Returns the key used to store the timeline of implementation contracts.
    */
    function implementationTimelineKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION_TIMELINE"));
    }

    /**
    * @dev Returns the key used to check if the initial implementation has been set.
    */
    function initialImplementationHasBeenSetKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIAL_IMPLEMENTATION_HAS_BEEN_SET"));
    }

    /**
    * @dev Returns the current implementation address.
    */
    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    /**
    * @dev Returns the implementation address at a specific timeline point.
    * @param implementationId The index of the implementation in the timeline.
    */
    function implementationTimeline(uint256 implementationId) public view virtual returns (address) {
        return _addressArray[implementationTimelineKey()][implementationId];
    }

    /**
    * @dev Returns the number of implementations in the timeline.
    */
    function implementationTimelineLength() public view virtual returns (uint256) {
        return _addressArray[implementationTimelineKey()].length;
    }

    /**
    * @dev Checks if the initial implementation has been set.
    */
    function initialImplementationHasBeenSet() public view virtual returns (bool) {
        return _bool[initialImplementationHasBeenSetKey()];
    }

    /**
    * @dev Sets the initial implementation if it has not been set yet.
    * @param implementation The address of the initial implementation.
    */
    function setInitialImplementation(address implementation) public virtual {
        _onlyWhenInitialImplementationHasNotBeenSet(implementation);
        _upgrade(implementation);
    }

    /**
    * @dev Internal function to get the current implementation address.
    * @return Address of the current implementation.
    */
    function _implementation() internal view virtual override returns (address) {
        return _address[implementationKey()];
    }

    /**
    * @dev Internal function to upgrade the implementation address.
    * @param implementation Address of the new implementation.
    */
    function _upgrade(address implementation) internal virtual {
        _address[implementationKey()] = implementation;
        _logUpgrade(implementation);
        emit Upgraded(implementation);
    }

    /**
    * @dev Internal function to log the upgrade in the implementation timeline.
    * @param implementation Address of the new implementation.
    */
    function _logUpgrade(address implementation) internal virtual {
        _addressArray[implementationTimelineKey()].push(implementation);
    }

    /**
    * @dev Modifier to ensure that the initial implementation has not been set.
    * @param implementation Address of the new implementation.
    */
    function _onlyWhenInitialImplementationHasNotBeenSet(address implementation) private {
        require(!initialImplementationHasBeenSet(), "Base: initialImplementationHasBeenSet()");
        _bool[initialImplementationHasBeenSetKey()] = true;
    }
}