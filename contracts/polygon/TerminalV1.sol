// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

/**
* version 0.5.0
*
* @dev A component is like a part that works in the protocol. Components 
*      often talk to other components, making the protocol interactions 
*      complex and hard to follow. The Terminal is in charge of improving 
*      our proxies. It helps the protocol handle its owned proxies in an 
*      organized way. It displays different states like supported, 
*      unsupported, paused, unpaused, and more. It also enables multiple 
*      upgrades to happen in a single transaction.
 */
contract TerminalV1 is ProxyStateOwnableContract {
    
    /** Events. */

    event ComponentDeployed(string indexed name, address indexed component);

    event ComponentUpgraded(string indexed name, address indexed component, address indexed implementation);

    event ComponentRenamed(string indexed oldName, string indexed newName);

    event ComponentPaused(string indexed name, address indexed component);

    event ComponentUnpaused(string indexed name, address indexed component);

    event ComponentSupported(string indexed name, address indexed component);

    event ComponentUnsupported(string indexed name, address indexed component);

    /** Public View. */

    function isSupported(string memory name) public view returns (bool) {
        return _bool[keccak256(abi.encode("_bool", "components", name, "supported"))];
    }

    /** Public. */

    function deployComponent(string memory name) public onlyOwner() whenNotPaused() returns (address) {
        require(_map(name) == 0, "TerminalV1: name is already assigned");
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        components.add(new ProxyStateOwnableContract());
        IProxyStateOwnable component = IProxyStateOwnable(components.at(components.length() - 1));
        component.initialize();
        _setMap(name, components.length()); /** Sub 1 to get actual index. */
        _bool[keccak256(abi.encode("_bool", "components", name, "supported"))] = true;
        emit ComponentDeployed(name, components.at(components.length() - 1));
        return components.at(components.length() - 1);
    }

    function upgradeComponent(string memory name, address implementation, bool initializeUnpaused) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(isSupported(name), "TerminalV1: component is unsupported");
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_map(name) - 1));
        component.pause();
        component.upgrade(implementation);
        if (initializeUnpaused) { component.unpause(); }
        _addressArray[keccak256(abi.encode("_addressArray", "components", name, "implementations"))].push(implementation);
        emit ComponentUpgraded(name, address(component), implementation);
    }

    function pauseComponent(string memory name) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(isSupported(name), "TerminalV1: component is unsupported");
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_map(name) - 1));
        component.pause();
        emit ComponentPaused(name, address(component));
    }

    function unpauseComponent(string memory name) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(isSupported(name), "TerminalV1: component is unsupported");
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_map(name) - 1));
        component.unpause();
        emit ComponentUnpaused(name, address(component));
    }

    function supportComponent(string memory name) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(!isSupported(name), "TerminalV1: component is supported");
        _bool[keccak256(abi.encode("_bool", "components", name, "supported"))] = true;
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_map(name) - 1));
        emit ComponentSupported(name, address(component));
    }

    function unsupportComponent(string memory name) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(isSupported(name), "TerminalV1: component is unsupported");
        _bool[keccak256(abi.encode("_bool", "components", name, "supported"))] = false;
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_map(name) - 1));
        emit ComponentUnsupported(name, address(component));
    }

    function renameComponent(string memory oldName, string memory newName) public onlyOwner() whenNotPaused() {
        require(_map(oldName) != 0, "TerminalV1: name is unassigned");
        uint index = _map(oldName);
        _setMap(newName, index);
        _setMap(oldName, 0);
        _bool[keccak256(abi.encode("_bool", "components", newName, "supported"))] = _bool[keccak256(abi.encode("_bool", "components", oldName, "supported"))];
        _bool[keccak256(abi.encode("_bool", "components", oldName, "supported"))] = false;
        emit ComponentRenamed(oldName, newName);
    }

    /** Private View. */

    function _map(string memory name) private view returns (uint256 index) {
        bytes32 location = keccak256(abi.encode("_uint256", "components", "map", name));
        return _uint256[location];
    }

    /** Private. */

    function _setMap(string memory name, uint256 index) private {
        bytes32 location = keccak256(abi.encode("_uint256", "components", "map", name));
        _uint256[location] = index;
    }
}