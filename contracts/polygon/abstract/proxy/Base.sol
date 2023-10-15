// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* NOTE: https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies
*
* implementationKey          => address
* implementationTimelineKey  => addressArray
* initialImplementationKey   => address
 */
abstract contract Base is Storage, Proxy {

    event Upgraded(address indexed implementation);

    function implementationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    function implementationTimelineKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION_TIMELINE"));
    }

    function initialImplementationKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIAL_IMPLEMENTATION"));
    }

    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    function implementationTimeline(uint256 implementationId) public view virtual returns (address) {
        return _addressArray[implementationTimelineKey()][implementationId];
    }

    function implementationTimelineLength() public view virtual returns (uint256) {
        return _addressArray[implementationTimelineKey()].length;
    }

    function initialImplementation() public view virtual returns (address) {
        return _address[initialImplementationKey()];
    }

    function setInitialImplementation(address implementation) public virtual {
        _onlyWhenInitialImplementationIsZero(implementation);
        _upgrade(implementation);
    }

    function _implementation() internal view virtual override returns (address) {
        return _address[implementationKey()];
    }

    function _upgrade(address implementation) internal virtual {
        _address[implementationKey()] = implementation;
        _logUpgrade(implementation);
    }

    function _logUpgrade(address implementation) internal virtual {
        _addressArray[implementationTimelineKey()].push(implementation);
    }

    function _onlyWhenInitialImplementationIsZero(address implementation) private {
        require(initialImplementation() == address(0), "Base: initialImplementation() != address(0)");
        _address[initialImplementationKey()] = implementation;
    }
}