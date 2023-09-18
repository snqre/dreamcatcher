// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

/** 0.0.0
* @dev Storage usage:
* _addressSet: "deployed"
* _bool: "nameInUse"
* _uint256: "stringToUintProxyMapping"
*
* @dev TerminalV1 is responsable for upgrading our proxies in a
*      an organized manner such that all upgrades can be found in one place.
*      It also allows to view active components, which ones are paused
*      or unpaused, and in what states they are in.
*      Previous implementations can be found as well, messages can be found on why
*      the upgrade happened and what new features have been added.
*
* NOTE Backward compatibility is something we try for.
*
* @dev To support a proxy which is not within our regular set up
*      it is important that the proxy is owned by Terminal.
*      The Proxy must also follow the DRC standards.
 */
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

    function rename(string memory name, string memory newName) public {

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
}