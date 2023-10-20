// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/abstracts/utils/lite/ConfigurableLite.sol";
import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";

contract ProxyLite is StorageLite, Proxy, ConfigurableLite {

    function implementation() public view virtual returns (address) {
        return _implementation();
    }

    function configure(address newImplementation) public virtual {
        _configure(newImplementation);
    }

    function ____implementation() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("IMPLEMENTATION"));
    }

    function _implementation() internal view virtual override returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____implementation()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____implementation()], (address));
    }

    function _configure(address newImplementation) internal virtual {
        super._configure();
        _bytes[____implementation()] = abi.encode(newImplementation);
    }

    function _beforeFallback() internal virtual override {
        super._beforeFallback();
        _mustBeConfigured();
    }
}