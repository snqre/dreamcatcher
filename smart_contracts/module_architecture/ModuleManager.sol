// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/access/Ownable.sol";

interface IModuleManager {
    /// custom error messages.
    error ModuleFound(string module);
    error ModuleNotFound(string module);
    error VersionFound(string module, uint version);
    error VersionNotFound(string module, uint version);
    error ImplementationFound(string module, address implementation);

    /// events.
    event ModuleAquired(string indexed module, address indexed implementation);
    event ModuleUpgraded(string indexed module, address indexed newImplementation);
}

contract ModuleManager is IModuleManager, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint public count; /// number of aquired modules.
    
    mapping(
        string => EnumerableSet.AddressSet
    ) private _implementations;
    string[] public modules;
    
    /// revert if given module name does point to a module.
    modifier onlyIfModuleNotFound(string memory module) {
        if (_implementations[module].length() == 0) { 
            revert ModuleFound(module); 
        }
        _;
    }

    /// revert if given module name does not point to a module.
    modifier onlyIfModuleFound(string memory module) {
        if (_implementations[module].length() >= 1) { 
            revert ModuleNotFound(module); 
        }
        _;
    }

    /// revert if version does point to an actual version.
    modifier onlyIfVersionNotFound(string memory module, uint version) {
        if (version > _getLatestVersion(module)) { 
            revert VersionFound(module, version);
        }
        _;
    }

    /// revert if version does not point to an actual version.
    modifier onlyIfVersionFound(string memory module, uint version) {
        if (version <= _getLatestVersion(module)) { 
            revert VersionNotFound(module, version); 
        }
        _;
    }

    /// revert if implementation does point to an already existing implementation.
    modifier onlyIfImplementationNotFound(string memory module, address implementation) {
        if (_implementations[module].contains(implementation)) {
            revert ImplementationFound(module, implementation);
        }
        _;
    }

    constructor() Ownable() {
        _transferOwnership(msg.sender);
    }

    /// get the latest version of a module.
    function _getLatestVersion(string memory module) 
    internal view virtual
    onlyIfModuleFound(module)
    returns (uint) {
        return _implementations[module].length() - 1;
    }

    /// get the latest address of module's implementation.
    function _getLatestImplementation(string memory module) 
    internal view virtual
    onlyIfModuleFound(module)
    returns (address) {
        uint latestVersion = _getLatestVersion(module);
        return _implementations[module].at(latestVersion);
    }

    /// get any address of the module's implementation.
    function _getImplementation(string memory module, uint version)
    internal view virtual
    onlyIfVersionFound(module, version)
    returns (address) {
        return _implementations[module].at(version);
    }

    /// create a new module construct.
    function aquire(string memory module, address implementation)
    external
    onlyOwner
    onlyIfModuleFound(module)
    returns (bool) {
        count ++;
        _implementations[module].add(implementation);
        emit ModuleAquired(module, implementation);
        modules.push(module);
        return true;
    }

    /// upgrade to the new implementation.
    function upgrade(string memory module, address newImplementation)
    public
    onlyOwner
    onlyIfModuleFound(module)
    returns (bool) {
        _implementations[module].add(newImplementation);
        emit ModuleUpgraded(module, newImplementation);
        return true;
    }

    /// public access view function to check latest version.
    function getLatestVersion(string memory module)
    public view
    returns (uint) {
        return _getLatestVersion(module);
    }

    /// public access points to latest implementation address.
    function getLatestImplementation(string memory module)
    public view
    returns (address) {
        return _getLatestImplementation(module);
    }

    /// public access points to implementation address.
    function getImplementation(string memory module, uint version)
    public view
    returns (address) {
        return _getImplementation(module, version);
    }
}