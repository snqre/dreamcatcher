// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

/**
* version 0.5.0
*
* _addressSet: "components"
* _bool: "nameInUse"
* _uint256: "stringToUintProxyMapping"
*
* @dev A component is how we name proxies that operate within the protocol.
*      A component is likely to call multiple other components therefore
*      interactions within the protocol can become complicated and difficult
*      to trace.
*
* @dev Terminal is responsable for upgrading our proxies. It allows the
*      protocol to manage owned proxies in an organized fashion. It shows
*      supported, unsupported, paused, unpaused, and other states.
*      It allows for multiple upgrades within the same transaction.
*
* NOTE It is important to keep backwards compatibility in mind.
 */
contract TerminalV is ProxyStateOwnableContract {

    /** Events. */

    event ComponentRenamed(string indexed oldName, string indexed newName);

    event ComponentUpgraded(address indexed implementation);

    event ComponentDeployed(string indexed name, address indexed newComponent);

    event ComponentPaused(string indexed name, address indexed component);

    /** External View. */

    function getModuleIndexed(uint index) external view
    returns (
        string memory,
        string memory,
        string memory,
        bool,
        bool,
        bool,
        bool,
        bool,
        address[] memory,
        address
    ) {
        bytes32 location = keccak256(abi.encode("components"));
        EnumerableSet.AddressSet storage components = _addressSet[location];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(index));
        location = keccak256(abi.encode("component", "name", address(component)));
        string memory name = _string[location];
        string memory message = _string[location];
    }

    /** Public. */

    /**
    * @dev Upgrade a component.
     */
    function upgradeComponent(string memory name, address implementation) public {
        bytes32 location = keccak256(abi.encode("components", "deployed"));
        EnumerableSet.AddressSet storage components = _addressSet[location];
        uint256 index = _getStringToUint256ProxyMapping(name) - 1;
        IProxyStateOwnable component = IProxyStateOwnable(components.at(index));
        /**
        * @dev When executing upgrade we pause the component.
         */
        component.pause();
        component.upgrade(implementation);
        component.unpause();
        emit ComponentUpgraded(implementation);
    }

    /**
    * @dev Batch upgrade multiple components.
     */
    function batchUpgradeComponents(string[] memory names, address[] memory implementations) public {
        /**
        * Pause all upgraded components.
         */
        batchPauseComponents(names);
        bytes32 location = keccak256(abi.encode("components", "deployed"));
        EnumerableSet.AddressSet storage components = _addressSet[location];
        for (uint256 i = 0; i < names.length; i++) {
            upgradeComponent(names[i], implementations[i]);
        }
        _batchUnpauseComponents(names);
    }

    /**
    * @dev Pause a component.
     */
    function pauseComponent(string memory name) public {
        bytes32 location = keccak256(abi.encode("components", "deployed"));
        EnumerableSet.AddressSet storage components = _addressSet[location];
        uint256 index = _getStringToUint256ProxyMapping(name) - 1;
        IProxyStateOwnable component = IProxyStateOwnable(components.at(index));
        component.pause();
        emit ComponentPaused(name, address(component));
    }

    function batchPauseComponents(string[] memory names) public {
        bytes32 location = keccak256(abi.encode("components", "deployed"));
        EnumerableSet.AddressSet storage components = _addressSet[location];
        for (uint256 i = 0; i < names.length; i++) {
            pauseComponent(names[i]);
        }
    }

    /** Internal View. */

    function _onlyNameAssigned(string memory name) internal view {
        bytes32 location = keccak256(abi.encode("nameIsAssigned", name));
        require(_bool[location], "TerminalV1: name unassigned");
    }

    function _onlyNameUnassigned(string memory name) internal view {

    }

    function _getStringToUint256ProxyMapping(string memory name) internal view returns (uint index) {
        return _uint256[keccak256(abi.encode("components", "stringToUint256ProxyMapping", name))];
    }

    /** Internal. */

    /** 
    * @dev Deploy a new proxy component.
     */
    function _deployComponent(string memory name) internal returns (address) {
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("components", "deployed"))];
        components.add(new ProxyStateOwnableContract());
        IProxyStateOwnable component = IProxyStateOwnable(components.at(components.length() - 1));
        component.initialize();
        _setStringToUintProxyMapping(name, components.length());
        /**
        * @dev Mapping should be subtracted by 1 when used. The reason
        *      is because zero is reserved as a default value the new mapping
        *      starts at 1, whilst the addressSet registers it at 0.
         */
        emit ComponentDeployed(name, components.at(components.length()));
        return components.at(components.length());
    }

    function _upgradeComponent(string memory name, address implementation) internal {
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_getStringToUint256ProxyMapping(name) - 1));
        /**
        * @dev When executing upgrades we pause the proxy before when make any change.
         */
        component.pause();
        component.upgrade(implementation);
        component.unpause();
        emit ComponentUpgraded(implementation);
    }

    /** TODO CHECK FOR NAMES BOTH FUNCTIONS */
    function _batchUpgradeComponents(string[] memory names, address[] memory implementations) internal {
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("components", "deployed"))];
        for (uint256 i = 0; i < names.length; i++) {
            IProxyStateOwnable component = IProxyStateOwnable(components.at(_getStringToUint256ProxyMapping(names[i]) - 1));
            component.pause();
        }
    }

    /**
    * @dev Pause a component.
     */
    function _pauseComponent(string memory name) internal {
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_getStringToUint256ProxyMapping(name) - 1));
        component.pause();
        emit ComponentPaused(name, address(component));
    }

    function _batchPauseComponents(string[] memory names) internal {

    }

    function _unpauseComponent(string memory name) internal {
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("components", "deployed"))];
        IProxyStateOwnable component = IProxyStateOwnable(components.at(_getStringToUint256ProxyMapping(name) - 1));
        component.unpause();
        
    }

    function _batchUnpauseComponent(string[] memory names) internal {
        EnumerableSet.AddressSet storage components = _addressSet[keccak256(abi.encode("components", "deployed"))];
        for (uint256 i = 0; i < names.length; i++) {
            IProxyStateOwnable component = IProxyStateOwnable(components.at(_getStringToUint256ProxyMapping(names[i]) - 1));
        }
    }

    function _setStringToUint256ProxyMapping(string memory name, uint index) internal {
        _uint256[keccak256(abi.encode("components", "stringToUint256ProxyMapping", name))] = index;
    }

    /**
    * @dev Rename and assign a new name to a component.
     */
    function _renameComponent(string memory name, string memory newName) internal {
        uint index = _getStringToUint256ProxyMapping(name);
        _setStringToUint256ProxyMapping(newName, index);
        _setStringToUint256ProxyMapping(name, 0);
        emit ComponentRenamed(name, newName);
    }

    /** Private. */

    
}


contract TerminalV1 is ProxyStateOwnableContract {

    event ComponentDeployed(string indexed name, address indexed newComponent);

    event ComponentUpgraded(address indexed newImplementation);

    event ComponentDowngraded();

    event ComponentRenamed(string indexed oldName, string indexed newName);

    event ComponentPaused(string indexed name, address indexed component);

    event ComponentUnpaused(string indexed name, address indexed component);

    event ComponentSupported(string indexed name, address indexed component);

    /** @dev If a component is unsupported it cannot be upgraded or is not intended to be upgraded any longer */
    event ComponentUnsupported(string indexed name, address indexed component);

    event ComponentOwnershipTransferred();

    event ComponentInitialized();

    modifier requireNameUnassigned(string memory name) {
        _requireNameUnassigned(name);
        _;
    }

    modifier requireNameAssigned(string memory name) {
        _requireNameAssigned(name);
        _;
    }

    /** External View. */

    function deployed(uint index) external view
    returns (
        string memory name,
        address implementation,
        address owner,
        bool paused,
        bool active,
        string[] memory dependencies,
        address[] memory addressDependencies
    ) {

    }

    function modulesSupported() external view;

    function modulesUnsupported() external view;

    function modulesPaused() external view;

    function modulesUnpaused() external view;

    function modules() external view;

    function modulesRecentlyUpgraded() external view;

    function modulesPreviousImplementations() external view;

    function modulesCurrentImplementation() external view;

    function modulesFutureImplementation() external view;



    /** External. */

    function deploy(string memory name) external requireNameUnassigned(name) {
        bytes32 location = keccak256(abi.encode("deployed"));
        EnumerableSet.AddressSet storage deployed =  _addressSet[location];
        deployed.add(new ProxyStateOwnableContract());
        uint current = deployed.length() - 1;
        IProxyStateOwnable iPSO = IProxyStateOwnable(deployed.at(current));
        iPSO.initialize();
        _setStringToUintProxyMapping(name, current);
    }

    /** Public. */

    /**
    * @dev Call proxy module to upgrade.
     */
    function upgradeModule(string memory name, address implementation) public onlyOwner {
        _requireNameAssigned(name);
        /** @dev Get addressSet for deployed proxies. */
        bytes32 location = keccak256(abi.encode("deployed"));
        EnumerableSet.AddressSet storage deployed = _addressSet[location];
        /** 
        * @dev Use uint to proxy mapping matching to get corresponding index
        *      also declare proxy interface.
         */
        uint index = _getStringToUintProxyMapping(name);
        IProxyStateOwnable iPSO = IProxyStateOwnable(deployed.at(index));
        /** @dev Pause before upgrade. */
        iPSO.pause();
        /** @dev Call upgrade. */
        iPSO.upgrade(implementation);
        /** @dev Unpause after upgrade. */
        iPSO.unpause();
    }

    /**
    * @dev Pause all proxies all at once, then upgrade, and then unpause
    *      this paused all proxies as this is suitable for proxies which are
    *      interconnected or call each other.
     */
    function batchUpgradeModule(string[] memory names, address[] memory implementations) public onlyOwner {
        
    }

    function renameModule(string memory name, string memory newName) public {

    }

    function pauseModule(string memory name) public {
        
    }



    /** Internal View. */

    function _getStringToUintProxyMapping(string memory name) internal view returns (uint index) {
        bytes32 location = keccak256(abi.encode("stringToUintProxyMapping", name));
        return _uint256[location];
    }

    function _requireNameUnassigned(string memory name) internal view {
        bytes32 location = keccak256(abi.encode("nameIsInUse", name));
        require(!_bool[location], "TerminalV1: name is assigned");
    }

    function _requireNameAssigned(string memory name) internal view {
        bytes32 location = keccak256(abi.encode("nameIsInUse", name));
        require(_bool[location], "TerminalV1: name is unassigned");
    }

    /** Internal. */

    function _setStringToUintProxyMapping(string memory name, uint index) internal {
        bytes32 location = keccak256(abi.encode("stringToUintProxyMapping", name));
        _uint256[location] = index;
    }

    /** Private. */
}