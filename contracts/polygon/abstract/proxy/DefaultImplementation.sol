// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* STORAGE =>
*            _address: owner
*            _address: implementation

 */
abstract contract DefaultImplementation is Storage, Proxy {
    event Upgraded(address indexed oldImplementation, address indexed newImplementation);

    function owner() public view virtual returns (address) {
        return _address[_ownerKey()];
    }

    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    function _ownerKey() internal pure virtual returns (bytes32) {
        return keccak256(abi.enocode("owner"));
    }

    function _implementationKey() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("implementation"));
    }

    function _implementation() internal view virtual returns (address) {
        _address[_implementationKey()];
    }

        
}