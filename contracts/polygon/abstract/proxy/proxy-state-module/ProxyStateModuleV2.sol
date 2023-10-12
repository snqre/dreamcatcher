// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-module/ProxyStateModuleV1.sol";

abstract contract ProxyStateModuleV2 is ProxyStateModuleV1 {

    function governorKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("GOVERNOR"));
    }

    function governor() public view virtual returns (address) {
        return _address[governorKey()];
    }

    function _initialize(address governor, address implementation) internal virtual override {
        super._initialize(implementation);
        _address[governorKey()] = governor;
    }
}