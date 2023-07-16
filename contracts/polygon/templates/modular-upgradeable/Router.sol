// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/Terminal.sol";

contract Router {
    using EnumerableSet for EnumerableSet.AddressSet;
    bool upgradeable;
    bool enabled;
    string id;
    address terminal;

    error ROUTER_DISABLED();
    error INVALID_VERSION();

    modifier onlyKey(uint id) {
        ITerminal(terminal).validate(msg.sender, self.requiredKeys[id]);
        _;
    }

    modifier onlyIfEnabled() {
        if (!self.enabled) { revert ROUTER_DISABLED(); }
        _;
    }

    constructor(string memory id, address implementation, string[30] requiredKeys, bool upgradeable, bool enabled) {
        self.implementations.add(implementation);
        self.upgradeable = upgradeable;
        self.enabled = enabled;
        self.id = id;
        self.terminal = msg.sender;
        self.requiredKeys = requiredKeys;
        self.latestImplementation = implementation;
        self.latestVersion = self.implementations.length() - 1;
    }

    function _onlyKey(bytes memory key)

    function enable()
        public
        onlyKey(0) {
        self.enabled = true;
    }

    function disable()
        public
        onlyKey(1) {
        self.enabled = false;
    }

    function upgrade(address implementation)
        public
        onlyIfEnabled
        onlyKey(2) {
        self.implementations.add(implementation);
        self.latestImplementation = implementation;
        self.latestVersion = self.implementations.length() - 1;
    }

    function downgrade(uint version)
        public
        onlyIfEnabled
        onlyKey(3) {
        if (version >= self.implementations.length()) { revert INVALID_VERSION(); }
        self.implementations.add(self.implementations.at(version));
    }

    function getLatestVersion()
        public
        onlyIfEnabled {
        return self.implementations.length() - 1;
    }


}