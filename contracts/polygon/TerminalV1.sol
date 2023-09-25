// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

/**
* version 0.5.0
*
* address       -> "map", <string/name>     -> <address/proxy>
* stringArray   -> "proxies", "names"       -> <stringArray/names>
* addressSet    -> "proxies", "deployed"    -> <addressSet/proxies>
* addressSet    -> "proxies", "supported"   -> <addressSet/proxies>
* addressSet    -> "history", <string/name> -> <addressSet/implementations>
 */
contract TerminalV1 is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    /** Events. */

    /**
    * @dev Emitted when TERMINAL deploys a new proxy.
     */
    event ProxyDeployed(string indexed name, address indexed proxy);
    
    /**
    * @dev Emitted when TERMINAL upgrades a supported proxy.
    *
    * WARNING: Upgrade pauses and unpauses proxies but the respective
    *          events are not emitted because the state returns to
    *          normal.
     */
    event ProxyUpgraded(string indexed name, address indexed proxy, address indexed implementation);

    /**
    * @dev Emitted when TERMINAL pauses a supported proxy.
     */
    event ProxyPaused(string indexed name, address indexed proxy);

    /**
    * @dev Emitted when TERMINAL unpauses a supported proxy.
     */
    event ProxyUnpaused(string indexed name, address indexed proxy);

    /**
    * @dev Emitted when TERMINAL releases a supported proxy.
    *      Turns a supported proxy into an unsupported proxy which
    *      cannot be manipulated by the TERMINAL.
     */
    event ProxyReleased(string indexed name, address indexed proxy);

    /** External View. */

    /**
    * @dev Search deployed proxies.
     */
    function getDeployed(uint256 index) external view returns (address) {

        return _addressSet[keccak256(abi.encode("proxies", "deployed"))].at(index);
    }

    /**
    * @dev Search supported proxies.
     */
    function getSupported(uint256 index) external view returns (address) {

        return _addressSet[keccak256(abi.encode("proxies", "supported"))].at(index);
    }

    /**
    * @dev Get latest implementation of proxy by name.
     */
    function getLatestImplementation(string calldata name) external view returns (address) {

        uint256 index = _addressSet[keccak256(abi.encode("history", name))].length();

        return _addressSet[keccak256(abi.encode("history", name))].at(index - 1);
    }

    /**
    * @dev Get history of implementations of proxy by name.
     */
    function getImplementation(string calldata name, uint256 index) external view returns (address) {

        return _addressSet[keccak256(abi.encode("history", name))].at(index);
    }

    /**
    * @dev Get latest version of a proxy.
     */
    function getVersion(string calldata name) external view returns (uint256 index) {

        return _addressSet[keccak256(abi.encode("history", name))].length();
    }

    /**
    * @dev Get all proxy names.
     */
    function getNames(uint256 index) external view returns (string memory) {

        return _stringArray[keccak256(abi.encode("proxies", "names"))][index];
    }

    /** External. */

    /**
    * @dev Deploys a proxy contract and assigns a name to it so it is
    *      more human readable. Proxies are searchable within the
    *      contract and can be refered to with names rather than
    *      addresses which are harder to read. Proxies are upgradeable
    *      and new functionality can be given to them. The idea is for
    *      the TERMINAL to be managed by the governor contract so that
    *      the community is directly responsible for granting
    *      permission to change functionality.
     */
    function deploy(string calldata name) external onlyOwner() whenNotPaused() returns (address) {
        
        /**
        * @dev Require name is not assigned to a proxy address. Assign
        *      name to deployed proxy address.
         */
        require(_address[keccak256(abi.encode("map", name))] == address(0), "TerminalV1: name is already assigned");
        _address[keccak256(abi.encode("map", name))] = address(new ProxyStateOwnableContract());
        
        /**
        * @dev Add newly deployed proxy to deployed proxies set.
        *
        * WARNING: We don't check if the address is already in the set
        *          because we don't expect the address to point to an
        *          existing contract when deployed.
         */
        _addressSet[keccak256(abi.encode("proxies", "deployed"))].add(_address[keccak256(abi.encode("map", name))]);
        
        /**
        * @dev Add newly deployed proxy to supported proxies set.
        *
        * NOTE: Only supported proxies are able to be upgraded, paused,
        *       unpaused, or mutated by TERMINAL. Released proxies are
        *       immutable as the Terminal renounces its ownership of
        *       them.
         */
        _addressSet[keccak256(abi.encode("proxies", "supported"))].add(_address[keccak256(abi.encode("map", name))]);

        /**
        * @dev Add used names to names array.
         */
        _stringArray[keccak256(abi.encode("proxies", "names"))].push(name);

        /**
        * @dev Initialize the newly deployed proxy contract to gain
        *      ownership of it.
        *
        * WARNING: If the initialize call is front run, this function
        *          SHOULD revert. The reason initialize must be called
        *          is because when using proxies contructors alter
        *          contracts on a byte code level. Therefore, they
        *          have to be disabled, and initialize must be called.
         */
        IProxyStateOwnable proxyInterface = IProxyStateOwnable(_address[keccak256(abi.encode("map", name))]);

        /**
        * @dev Function execution within ProxyStateOwnable for 
        *      initialize().
        *
        * bytes32 location = keccak256(abi.encode("$initialized"));
        * require(!_bool[location], "ProxyStateOwnable: already initialized");
        * _transferOwnership(_msgSender());
        * location = keccak256(abi.encode("$paused"));
        * _bool[location] = false;
        * location = keccak256(abi.encode("$initialized"));
        * _bool[location] = true;
        * emit Initialized(_msgSender());
         */
        proxyInterface.initialize();

        emit ProxyDeployed(name, _address[keccak256(abi.encode("map", name))]);

        return address(proxyInterface);
    }

    /**
    * @dev Upgrades a proxy with new functionality. Will pause, before
    *      the upgrade, and then unpause after the upgrade. Refer to
    *      the proxy by name.
     */
    function upgradeTo(string calldata name, address implementation) external onlyOwner() whenNotPaused() {

        /**
        * @dev Require name is assigned to a proxy address.
         */
        require(_address[keccak256(abi.encode("map", name))] != address(0), "TerminalV1: name is unassigned");

        /**
        * @dev Require that the proxy is supported.
         */
        require(_addressSet[keccak256(abi.encode("proxies", "supported"))].contains(_address[keccak256(abi.encode("map", name))]), "TerminalV1: proxy is unsupported");
        
        IProxyStateOwnable proxyInterface = IProxyStateOwnable(_address[keccak256(abi.encode("map", name))]);

        /**
        * @dev If proxy is unpaused when upgraded the proxy is paused
        *      and once it is upgraded it returns to the unpaused
        *      state.
         */
        if (!proxyInterface.paused()) {

            proxyInterface.pause();

            proxyInterface.upgrade(implementation);

            proxyInterface.unpause();
        }

        /**
        * @dev If proxy is paused when upgraded the proxy remains paused
        *      during the upgrade and stays in the state it was.
         */
        else {

            proxyInterface.upgrade(implementation);
        }
        
        /**
        * @dev Add new implementation to the proxy's implementation
        *      history.
        *
        * WARNING: addressSet will not add duplicate entries. If the upgrade
        *          is to an older implementation, the new implementation
        *          will not be added as a new one. If it is an older
        *          version that has been implemented it can be viewed
        *          within the addressSet.
         */
        _addressSet[keccak256(abi.encode("history", name))].add(implementation);
        
        emit ProxyUpgraded(name, _address[keccak256(abi.encode("map", name))], implementation);
    }

    /**
    * @dev Pauses a supported proxy.
     */
    function pause_(string calldata name) external onlyOwner() whenNotPaused() {

        /**
        * @dev Require name is assigned to a proxy address.
         */
        require(_address[keccak256(abi.encode("map", name))] != address(0), "TerminalV1: name is unassigned");

        /**
        * @dev Require that the proxy is supported.
         */
        require(_addressSet[keccak256(abi.encode("proxies", "supported"))].contains(_address[keccak256(abi.encode("map", name))]), "TerminalV1: proxy is unsupported");

        IProxyStateOwnable proxyInterface = IProxyStateOwnable(_address[keccak256(abi.encode("map", name))]);

        proxyInterface.pause();

        emit ProxyPaused(name, _address[keccak256(abi.encode("map", name))]);
    }

    /**
    * @dev Unpauses a supported proxy.
     */
    function unpause_(string calldata name) external onlyOwner() whenNotPaused() {

        /**
        * @dev Require name is assigned to a proxy address.
         */
        require(_address[keccak256(abi.encode("map", name))] != address(0), "TerminalV1: name is unassigned");

        /**
        * @dev Require that the proxy is supported.
         */
        require(_addressSet[keccak256(abi.encode("proxies", "supported"))].contains(_address[keccak256(abi.encode("map", name))]), "TerminalV1: proxy is unsupported");

        IProxyStateOwnable proxyInterface = IProxyStateOwnable(_address[keccak256(abi.encode("map", name))]);

        proxyInterface.unpause();

        emit ProxyUnpaused(name, _address[keccak256(abi.encode("map", name))]);
    }

    /**
    * @dev Release a supported proxy so it will not be supported anymore
    *      and TERMINAL will not have ownership anymore.
     */
    function release(string calldata name) external onlyOwner() whenNotPaused() {

        /**
        * @dev Require name is assigned to a proxy address.
         */
        require(_address[keccak256(abi.encode("map", name))] != address(0), "TerminalV1: name is unassigned");

        /**
        * @dev Require that the proxy is supported.
         */
        require(_addressSet[keccak256(abi.encode("proxies", "supported"))].contains(_address[keccak256(abi.encode("map", name))]), "TerminalV1: proxy is unsupported");

        IProxyStateOwnable proxyInterface = IProxyStateOwnable(_address[keccak256(abi.encode("map", name))]);

        proxyInterface.renounceOwnership();

        /**
        * @dev Remove the released proxy from the addressSet of supported
        *      proxies.
         */
        _addressSet[keccak256(abi.encode("proxies", "supported"))].remove(_address[keccak256(abi.encode("map", name))]);

        emit ProxyReleased(name, _address[keccak256(abi.encode("map", name))]);
    }
}