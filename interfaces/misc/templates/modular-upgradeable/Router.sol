// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";

contract Router is Pausable{
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _implementations;

    string public name_;
    address public hub;
    constructor(string memory name__, address hub_) {
        hub = hub_;
        name_ = name__;
    }

    function upgrade(address implementation)
        public 
        whenNotPaused {
        IHub(hub).validate(msg.sender, address(this), "upgrade");
        _implementations.add(implementation);
    }

    function downgrade(uint version)
        public 
        whenNotPaused {
        /// will simply place previous version at the end of the AddressSet
        IHub(hub).validate(msg.sender, address(this), "downgrade");
        _implementations.remove(_implementations.at(version));
        _implementations.add(_implementations.at(version));
    }

    function pause()
        public {
        IHub(hub).validate(msg.sender, address(this), "pause");
        _pause();
    }

    function unpause()
        public {
        IHub(hub).validate(msg.sender, address(this), "unpause");
        _unpause();
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

    /// for organization each router has a callable name
    /// this is also useful for universal routers
    function name()
        public view
        returns (string memory) {
        return name_;
    }
}