// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/errors/Errors.sol";

/**
 The router will route any calls to the latest implementation
 */

contract Router {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private implementations;
    address public latestImplementation;
    uint public latestVersion;
    bool public upgradeable;
    bool public enabled;
    string public name;

    address terminal;

    error IsNotEnabled();

    modifier onlyIfEnabled() {
        if (!enabled) { revert IsNotEnabled();_; }
    }

    constructor(string name_, address implementation, bool upgradeable_, bool enabled_) {
        implementations.add(implementation);
        latestImplementation = implementation;
        latestVersion = implementations.length() - 1;
        upgradeable = upgradeable_;
        enabled = enabled_;
        name = name;

        // routers are only meant to be deployed from a terminal.
        terminal = msg.sender;
    }

    function enable()
        external 
        returns (bool) {
        ITerminal(terminal).authenticate(msg.sender, string(abi.encodePacked(name, "->enable()")));
        enabled = true;
        return true;
    }

    function disable()
        external
        returns (bool) {
        ITerminal(terminal).authenticate(msg.sender, string(abi.encodePacked(name, "->disable()")));
        enabled = false;
        return true;
    }

    function upgrade(address implementation)
        external
        returns (bool) {
        ITerminal(terminal).authenticate(msg.sender, string(abi.encodePacked(name, "->upgrade()")));
        implementations.add(implementation);
        return true;
    }

    function downgrade(uint version)
        external
        returns (bool) {
        ITerminal(terminal).authenticate(msg.sender, string(abi.encodePacked(name, "->downgrade()"))); 
        implementations.add(implementations.at(version));
        return true;
    }

    function swapTerminal(address terminal_)
        external
        onlyIfEnabled
        returns (bool) {
        ITerminal(terminal).authenticate(msg.sender, string(abi.encodePacked(name, "->swapTerminal()")));
        terminal = terminal_;
    }

    function getImplementation(uint version)
        external view
        returns (address) {
        return implementations.at(version);
    }

    fallback()
        external
        onlyIfEnabled
        returns (bool, bytes memory) {
        (bytes4 signature, bytes memory args) = abi.decode(msg.data, (bytes4, bytes));

        bool success;
        bytes memory response;

        /// @dev should pass the original caller to the fallback function of the router.
        (success, response) = latestImplementation.call{value: msg.sender}(abi.encodeWithSignature(signature, args));
        
        return (success, response);
    }    
}