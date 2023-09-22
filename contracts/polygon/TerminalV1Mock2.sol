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

    /** Function Modifiers. */

    modifier onlyNameUnassigned(string memory name) {
        _onlyNameUnassigned(name);
        _;
    }

    modifier onlyNameAssigned(string memory name) {
        _onlyNameAssigned(name);
        _;
    }

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

    /**
    * @dev Update a deployed and supported component.
    *
    * @param versionTag eg. 0.5.0 or 13.5.0
     */
    function upgradeComponent(string memory name, string memory versionTag, address implementation) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(isSupported(name), "TerminalV1: component is unsupported");
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("_addressSet", "components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_map(name) - 1));
        component.pause();
        component.upgrade(implementation);
        component.unpause();
        _addressArray[keccak256(abi.encode("_addressArray", "components", name, "implementations"))].push(implementation);
        _stringArray[keccak256(abi.encode("_stringArray", "components", name, "versionTags"))].push(versionTag);
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

    function editVersionTag(string memory name, uint256 index, string memory versionTag) public onlyOwner() whenNotPaused() {
        require(_map(name) != 0, "TerminalV1: name is unassigned");
        require(isSupported(name), "TerminalV1: component is unsupported");
        _stringArray[keccak256(abi.encode("_stringArray", "components", name, "versionTags"))][index] = versionTag;
    }

    /** Private Pure. */

    /**
    * @dev Get bytes32 location to access the specified storage type.
    *      For Terminal.
    *
    * eg. _bool or _string
     */
    function _getKey(string memory storageType, string memory property) private pure returns (bytes32) {
        /**
        * > storageType
        * -- > property
         */
        return keccak256(abi.encode(storageType, property));
    }

    /**
    * @dev Get bytes32 location to access the specified storage type.
    *
    * eg. _bool or _string
     */
    function _getComponentKey(string memory storageType, string memory name, string memory property) private pure returns (bytes32) {
        /**
        * @dev Whilst it may seam redundant to encode the storage type
        *      it reduces the chances of incorrect storage use as it 
        *      forces dev to write the storage type in use as a reminder.
        *
        * > storageType
        * -- > component name
        * ----- > property
         */
        return keccak256(abi.encode(storageType, name, property));
    }

    /** Private View. */

    function _onlyNameUnassigned(string memory name) private view {
        require(!_bool[_getComponentKey("_bool", name, "nameIsAssigned")], "TerminalV1: name is assigned");
    }

    function _onlyNameAssigned(string memory name) private view {
        require(_bool[_getComponentKey("_bool", name, "nameIsAssigned")], "TerminalV1: name is unassigned");
    }

    /**
    * @dev Mapping maps the name used for a component to its location in the set.
    *
    * NOTE If the map points to zero it means it is default.
    *      Several maps will point to component zero which is deployed
    *      as an empty component. 
    * 
    * WARNING: COMPONENT ZERO IS NOT MEANT TO BE USED.
     */
    function _map(string memory name) private view returns (uint256 index) {
        return _uint256[_getComponentKey("_uint256", name, "map")];
    }

    function _components() private view returns (EnumerableSet.AddressSet components) {
        components = _addressSet[_getKey("_addressSet", "components")];
        return components;
    }

    /** Private. */

    /**
    * @dev The next time the _map is called it should point to the 
    *      location of the component address in the set.
     */
    function _setMap(string memory name, uint256 index) private {
        _uint256[_getComponentKey("_uint256", name, "map")] = index;
    }

    function _pushNewComponent(address component, string memory name, string memory description) private returns (uint256 index) {
        _addressSet[_getKey("_addressSet", "components")].add(component);
        index = _addressSet[_getKey("_addressSet", "components")].length() - 1;

        _setMap(name, index);
        return index;
    }

    function _setDescription(string memory name, string memory description) private {
        _string[keccak256(abi.encode("_string", "components", name, "description"))] = description;
    }

    function _clear(string memory name) private {
        delete _string[keccak256(abi.encode("_string", "components", name, "description"))];
    }
}