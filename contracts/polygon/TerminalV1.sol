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
* addressSet    -> "proxies", "deployed"    -> <addressSet/proxies>
* addressSet    -> "proxies", "supported"   -> <addressSet/proxies>
* addressSet    -> "proxies", "paused"      -> <addressSet/proxies>
*       
 */






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
*
* _address:         "map", <string/name>        -> <address/component>
* _addressSet:      "components", "deployed"    -> <addressSet/components>
*
* 
 */
contract TerminalV1B is ProxyStateOwnableContract {

    /** Events. */

    /**
    * @dev Fired when a new proxy is deployed.
     */
    event ProxyDeployed(string indexed name, address indexed proxy);

    /**
    * @dev Fired when a proxy is upgraded.
     */
    event ProxyUpgraded(string indexed name, address indexed proxy, address indexed implementation);

    /**
    * @dev Fired when a proxy is paused.
     */
    event ProxyPaused(string indexed name, address indexed proxy);

    /**
    * @dev Fired when a proxy is unpaused.
     */
    event ProxyUnpaused(string indexed name, address indexed proxy);

    /**
    * @dev Fired when a proxy is let go off. Unsupported proxies cannot
    *      be called and do not have owners, this means they are
    *      immutable and cannot be changed afterwards. users should
    *      not expect anymore upgrades for that proxy.
     */
    event ProxyUnsupported(string indexed name, address indexed proxy);

    /**
    * @dev Fired when a proxy is imported typically an alternative way
    *      of assigning a new proxy to a name.
    *
    * WARNING: Imported proxies will be called using the same interface
    *          as deployed proxies.
     */
    event ProxyImported(string indexed name, address indexed proxy);

    /** External. */

    /**
    * @dev Deploy proxy.
     */
    function deployProxy(string calldata name) external onlyOwner() whenNotPaused() returns (address) {
        return _deployProxy(name);
    }

    /**
    * @dev Import proxy.
     */
    function importProxy(string calldata name, address proxy) external onlyOwner() whenNotPaused() {
        _importProxy(name, proxy);
    }

    /**
    * @dev Upgrade proxy.
     */
    function upgradeProxy(string calldata name, address implementation) external onlyOwner() whenNotPaused() {
        _upgradeProxy(name, implementation);
    }

    /**
    * @dev Pause proxy.
     */
    function pauseProxy(string calldata name) external onlyOwner() whenNotPaused() {
        _pauseProxy(name);
    }

    /**
    * @dev Unpause proxy.
     */
    function unpauseProxy(string calldata name) external onlyOwner() whenNotPaused() {
        _unpauseProxy(name);
    }

    /**
    * @dev Unsupport proxy.
     */
    function unsupportProxy(string calldata name) external onlyOwner() whenNotPaused() {
        _unsupportProxy(name);
    }

    /** Internal View. */

    /**
    * @dev Get name to proxy mapping. Name will return the address of the
    *      deployed or imported proxy. If the name has not been assigned
    *      will return address(0).
     */
    function _getMap(string calldata name) internal view returns (address) {
        return _address[keccak256(abi.encode(name, "mapping"))];
    }

    /** Internal. */
    
    /**
    * @dev Set name to proxy mapping. Assign a proxy address to a name of
    *      a deployed or imported proxy.
     */
    function _setMap(string calldata name, address proxy) internal {
        _address[keccak256(abi.encode(name, "mapping"))] = proxy;
    }

    /**
    * @dev Deploy a new proxy.
     */
    function _deployProxy(string calldata name) internal returns (address) {
        /** Require that the name is not assigned to a proxy address. */
        require(_getMap(name) == address(0), "TerminalV1: assigned");
        _setMap(name, new ProxyStateOwnableContract());
        IProxyStateOwnable proxy = IProxyStateOwnable(_getMap(name));
        proxy.initialize();
        /** Append proxy in deployed array. */
        EnumerableSet.AddressSet storage proxies = _addressSet[keccak256(abi.encode("components", "deployed"))];
        proxies.add(address(proxy));
        /** Return. */
        emit ProxyDeployed(name, address(proxy));
        return address(proxy);
    }

    /**
    * @dev Import and assign a new proxy.
     */
    function _importProxy(string calldata name, address proxy) internal {
        /** Require that the name is not assigned to a proxy address. */
        require(_getMap(name) == address(0), "TerminalV1: assigned");
        _setMap(name, proxy);
        /** Here we assume the proxy is already initialized when imported. */
        /** Append proxy in deployed array. */
        EnumerableSet.AddressSet storage proxies = _addressSet[keccak256(abi.encode("components", "deployed"))];
        proxies.add(proxy);
        /** Return. */
        emit ProxyImported(name, proxy);
    }

    /**
    * @dev Upgrade a proxy.
     */
    function _upgradeProxy(string calldata name, address implementation) internal {
        /** Require that the name is assigned to a proxy address. */
        require(_getMap(name) != address(0), "TerminalV1: unassigned");
        IProxyStateOwnable proxy = IProxyStateOwnable(_getMap(name));
        proxy.pause();
        proxy.upgrade(implementation);
        proxy.unpause();
        /** 
        * Append new implementation to proxy upgrade history. Duplicate
        * entries are not added but remain in the position it was in.
        * The upgrade will still occur but it will point to an older
        * version within the proxy history addressSet.
        */
        EnumerableSet.AddressSet storage proxyHistory = _addressSet[keccak256(abi.encode(name, "history"))];
        proxyHistory.add(implementation);
        emit ProxyUpgraded(name, address(proxy), implementation);
    }

    /**
    * @dev Pause proxy.
     */
    function _pauseProxy(string calldata name) internal {
        /** Require that the name is assigned to a proxy address. */
        require(_getMap(name) != address(0), "TerminalV1: unassigned");
        IProxyStateOwnable proxy = IProxyStateOwnable(_getMap(name));
        proxy.pause();
        /** Append to paused proxy array. */
        EnumerableSet.AddressSet storage pausedProxies = _addressSet[keccak256(abi.encode("paused"))];
        pausedProxies.add(address(proxy));
        emit ProxyPaused(name, address(proxy));
    }

    /**
    * @dev Unpause proxy.
     */
    function _unpauseProxy(string calldata name) internal {
        /** Require that the name is assigned to a proxy address. */
        require(_getMap(name) != address(0), "TerminalV1: unassigned");
        IProxyStateOwnable proxy = IProxyStateOwnable(_getMap(name));
        proxy.unpause();
        /** Remove from paused proxy array. */
        EnumerableSet.AddressSet storage pausedProxies = _addressSet[keccak256(abi.encode("paused"))];
        pausedProxies.remove(address(proxy));
        emit ProxyUnpaused(name, address(proxy));
    }

    /**
    * @dev Unsupport a proxy and renounce ownership.
     */
    function _unsupportProxy(string calldata name) internal {
        /** Require that the name is assigned to a proxy address. */
        require(_getMap(name) != address(0), "TerminalV1: unassigned");
        IProxyStateOwnable proxy = IProxyStateOwnable(_getMap(name));
        proxy.renounceOwnership();
        /** Append to unsupported proxy array. */
        EnumerableSet.AddressSet storage unsupportedProxies = _addressSet[keccak256(abi.encode("unsupported"))];
        unsupportedProxies.add(address(proxy));
        emit ProxyUnsupported(name, address(proxy));
    }
}