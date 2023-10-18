// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";
import "contracts/polygon/abstract/storage/StorageLite.sol";
import "contracts/polygon/abstract/utils/ConfigurableLite.sol";

abstract contract Foundation is StorageLite, ConfigurableLite, Proxy {

    event Upgraded(address indexed sender, address indexed implementation);

    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    function version(uint i) public view virtual returns (address) {
        return abi.decode(_bytes[____version(i)], (address));
    }

    function versionLength() public view virtual returns (uint) {
        return abi.decode(_bytes[____versionCount()], (uint));
    }

    function configure(address implementation) public virtual {
        _configure(implementation);
    }

    function ____implementation() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    function ____version(uint i) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("VERSION", i));
    }

    function ____versionCount() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("VERSION_COUNT"));
    }

    function _implementation() internal view virtual override returns (address) {
        return abi.decode(_bytes[____implementation()], (address));
    }

    function _configure(address implementation) internal virtual override {
        _upgrade(implementation);
        super._configure();
    }

    function _upgrade(address implementation) internal virtual {
        _bytes[____implementation()] = abi.encode(implementation);
        _logUpgrade(implementation);
        emit Upgraded(msg.sender, implementation);
    }

    function _logUpgrade(address implementation) internal virtual {
        uint i = _raiseVersion();
        _bytes[____version(i)] = abi.encode(implementation);
    }

    function _raiseVersion() internal virtual returns (uint) {
        uint i = abi.decode(_bytes[____versionCount()], (uint));
        i++;
        _bytes[____versionCount()] = abi.encode(i);
        return i;
    }
}