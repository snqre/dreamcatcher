// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/deps/openzeppelin/access/Ownable.sol";
import "contracts/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IModuleManager {
    event ModuleAquired(string indexed module, address implementation);
    event ModuleUpgraded(string indexed module, address newImplementation);
}

contract ModuleManager is IModuleManager, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint256 public numberOfModules;

    mapping(string => EnumerableSet.AddressSet) private _implementations;
    string[] public modules;

    modifier onlyIfModuleWasNotFound(string memory module) {
        require(_implementations[module].length() == 0, "ModuleManager: Module was found.");
        _;
    }

    modifier onlyIfModuleWasFound(string memory module) {
        require(
            _implementations[module].length() >= 1,
            "ModuleManager: Module was not found."
        );
        _;
    }

    modifier onlyIfVersionWasNotFound(string memory module, uint256 version) {
        require(version > _getLatestVersion(module), "Version was found.");
        _;
    }

    modifier onlyIfVersionWasFound(string memory module, uint256 version) {
        require(version <= _getLatestVersion(module), "ModuleManager: Version was not found.");
        _;
    }

    modifier onlyIfImplementationWasNotFound(
        string memory module,
        address implementation
    ) {
        require(
            _implementations[module].contains(implementation),
            "ModuleManager: Implementation was found."
        );
        _;
    }

    constructor(address owner) Ownable(owner) {}

    function _getLatestVersion(string memory module)
        internal
        view
        virtual
        onlyIfModuleWasFound(module)
        returns (uint256)
    {
        return _implementations[module].length() - 1;
    }

    function _getLatestImplementation(string memory module)
        internal
        view
        virtual
        onlyIfModuleWasFound(module)
        returns (address)
    {
        return _implementations[module].at(_getLatestVersion(module));
    }

    function _getImplementation(string memory module, uint256 version)
        internal
        view
        virtual
        onlyIfVersionWasFound(module, version)
        returns (address)
    {
        return _implementations[module].at(version);
    }

    function _aquire(string memory module, address implementation)
        internal
        virtual
        onlyOwner
        onlyIfModuleWasNotFound(module)
        returns (bool)
    {
        numberOfModules++;
        _implementations[module].add(implementation);

        modules.push(module);

        emit ModuleAquired(module, implementation);
        return true;
    }

    function _upgrade(string memory module, address newImplementation)
        internal
        virtual
        onlyOwner
        onlyIfModuleWasFound(module)
        returns (bool)
    {
        _implementations[module].add(newImplementation);

        emit ModuleUpgraded(module, newImplementation);
        return true;
    }

    function aquire(string memory module, address implementation)
        external
        returns (bool)
    {
        return _aquire(module, implementation);
    }

    function upgrade(string memory module, address newImplementation)
        external
        returns (bool)
    {
        return _upgrade(module, newImplementation);
    }

    function getLatestVersion(string memory module)
        external
        view
        returns (uint256)
    {
        return _getLatestVersion(module);
    }

    function getLatestImplementation(string memory module)
        external
        view
        returns (address)
    {
        return _getLatestImplementation(module);
    }

    function getImplementation(string memory module, uint256 version)
        external
        view
        returns (address)
    {
        return _getImplementation(module, version);
    }
}
