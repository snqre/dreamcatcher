// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

contract Router {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _implementations;

    address hub;
    constructor(address hub_) {
        hub = hub_;
    }

    function upgrade(address implementation)
        public {
        IHub(hub).validate(msg.sender, address(this), "upgrade");
        _implementations.add(implementation);
    }

    function getLatestVersion()
        public view
        returns (uint) {
        return _implementations.length() - 1;
    }

    function getLatestImplementation()
        public view
        returns (address) {
        return _implementations.at(getLatestVersion());
    }
}