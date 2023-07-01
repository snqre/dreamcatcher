// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/deps/openzeppelin/access/Ownable.sol";
import "contracts/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IModuleManager {}

contract ModuleManager is IModuleManager, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint public numberOfModules;

    mapping(string => EnumerableSet.AddressSet) private _implementations;
    string[] public modules;

    modifier onlyIfModuleWasNotFound(string memory module) {
        require(_implementations[module].length() == 0, "Module was found.");
        _;
    }

    modifier onlyIfModuleWasFound(string memory module) {
        require(
            _implementations[module].length() >= 1,
            "Module was not found."
        );
        _;
    }

    modifier onlyIfVersionWasNotFound(string memory module, uint version) {
        require(version > _getLatestVersion(module), "Version was found.");
        _;
    }

    modifier onlyIfVersionWasFound(string memory module, uint version) {
        require(version <= _getLatestVersion(module), "Version was not found.");
        _;
    }

    modifier onlyIfImplementationWasNotFound(
        string memory module,
        address implementation
    ) {
        require(
            _implementations[module].contains(implementation),
            "Implementation was found."
        );
        _;
    }

    constructor() Ownable() {}

    function _getLatestVersion(
        string memory module
    ) internal view virtual onlyIfModuleWasFound(module) returns (uint) {
        return _implementations[module].length() - 1;
    }

    function _getLatestImplementation(
        string memory module
    ) internal view virtual onlyIfModuleWasFound(module) returns (address) {
        return _implementations[module].at(_getLatestVersion(module));
    }

    function _getImplementation(
        string memory module,
        uint version
    )
        internal
        view
        virtual
        onlyIfVersionWasFound(module, version)
        returns (address)
    {
        return _implementation[module].at(version);
    }

    function _aquire(
        string memory module,
        address implementation
    )
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

    function _upgrade(
        string memory module,
        address newImplementation
    ) internal virtual onlyOwner onlyIfModuleWasFound(module) returns (bool) {
        _implementations[module].add(newImplementation);

        emit ModuleUpgraded(module, newImplementation);
        return true;
    }

    function aquire(
        string memory module,
        address implementation
    ) external returns (bool) {
        return _aquire(module, implementation);
    }

    function upgrade(
        string memory module,
        address newImplementation
    ) external returns (bool) {
        return _upgrade(module, newImplementation);
    }

    function getLatestVersion(
        string memory module
    ) external view returns (uint) {
        return _getLatestVersion(module);
    }

    function getLatestImplementation(
        string memory module
    ) external view returns (uint) {
        return _getLatestImplementation(module);
    }

    function getImplementation(
        string memory module,
        uint version
    ) external view returns (address) {
        return _getImplementation(module, version);
    }
}
