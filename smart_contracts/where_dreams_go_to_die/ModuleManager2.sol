// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IModuleManager {
    event ModuleGrantedKeyHolder(
        string indexed module
    );

    event ModuleRevokedKeyHolder(
        string indexed module
    );

    event ModuleGrantedUpgradeable(
        string indexed module
    );

    event ModuleRevokedUpgradeable(
        string indexed module
    );

    event ModuleAquired(
        string indexed module,
        address indexed implementation,
        bool isImmutable
    );

    event ModuleUpgraded(
        string indexed module,
        address indexed newImplementation
    );

    error ModuleFound(
        string module
    );

    error ModuleNotFound(
        string module
    );

    error VersionFound(
        string module,
        uint version
    );

    error VersionNotFound(
        string module,
        uint version
    );

    error DuplicateImplementationFound(
        string module,
        address implementation
    );

    error ModuleIsNotKeyHolder(
        string module
    );

    error IsNotKeyHolder(
        address caller
    );

    error ModuleIsNotUpgradeable(
        string module
    );

    error ModuleIsImmutable(
        string module
    );
}

contract ModuleManager is IModuleManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint public numberOfModules;

    mapping(
        string => EnumerableSet.AddressSet
    ) private _implementations;
    mapping(string => bool) public isKeyHolder;
    mapping(string => bool) public isImmutable;
    string[] public modules;

    constructor() {}

    function _mustNotBeExistingModule(
        string memory module
    ) internal view virtual {
        if (_implementations[module].length() == 0) {
            revert ModuleFound(module);
        }
    }

    function _mustBeExistingModule(
        string memory module
    ) internal view virtual {
        if (_implementations[module].length() >= 1) {
            revert ModuleNotFound(module);
        }
    }

    function _mustNotBeExistingVersion(
        string memory module,
        uint version
    ) internal view virtual {
        if (version > _getLatestVersion(module)) {
            revert VersionFound(
                module,
                version
            );
        }
    }

    function _mustBeExistingVersion(
        string memory module,
        uint version
    ) internal view virtual {
        if (version <= _getLatestVersion(module)) {
            revert VersionNotFound(
                module,
                version
            );
        }
    }

    function _mustNotBeDuplicateImplementation(
        string memory module,
        address implementation
    ) internal view virtual {
        if (!_implementations[module].contains(implementation)) {
            revert DuplicateImplementationFound(
                module,
                implementation
            );
        }
    }

    function _mustBeKeyHolder(
        string memory module
    ) internal view virtual {
        /// module must be key holder.
        if (!isKeyHolder[module]) {
            revert ModuleIsNotKeyHolder(module);
        }

        else {
            /// caller address must be latest implementation of the key holder module.
            if (msg.sender != _getLatestImplementation(module)) {
                revert IsNotKeyHolder(msg.sender);
            }
        }
    }

    function _mustNotBeImmutable(
        string memory module
    ) internal view virtual {
        if (isImmutable[module]) {
            revert ModuleIsImmutable(module);
        }
    }

    function _getLatestVersion(
        string memory module
    ) internal view virtual
    returns (uint) {
        /// return the latest version of a module.
        return _implementations[module].length() - 1;
    }

    function _getLatestImplementation(
        string memory module
    ) internal view virtual
    returns (address) {
        /// return the latest implementation address of a module.
        _mustBeExistingModule(module);
        uint latestVersion = _getLatestVersion(module);
        return _implementations[module].at(latestVersion);
    }

    function _getImplementation(
        string memory module,
        uint version
    ) internal view virtual
    returns (address) {
        /// return the implementation address of a specific version.
        _mustBeExistingModule(module);

        _mustBeExistingVersion(
            module, 
            version
        );

        return _implementations[module].at(version);
    }

    function _grantKeyHolder(
        string memory module
    ) internal virtual
    returns (bool) {
        isKeyHolder[module] = true;

        emit ModuleGrantedKeyHolder(module);
        return true;
    }

    function _revokeKeyHolder(
        string memory module
    ) internal virtual
    returns (bool) {
        isKeyHolder[module] = false;

        emit ModuleRevokedKeyHolder(module);
        return true;
    }

    function _aquire(
        string memory module,
        address implementation,
        bool isImmutable_
    ) internal virtual
    returns (bool) {
        _mustNotBeExistingModule(module);
        numberOfModules ++;
        _implementations[module].add(implementation);

        emit ModuleAquired(
            module,
            implementation,
            isImmutable_
        );

        /// set if this module is immutable.
        isImmutable[module] = isImmutable_;

        modules.push(module);
        return true;
    }

    function _upgrade(
        string memory module,
        address newImplementation
    ) internal virtual
    returns (bool) {
        _mustBeExistingModule(module);
        _mustNotBeImmutable(module);
        _implementations[module].add(newImplementation);

        emit ModuleUpgraded(
            module,
            newImplementation
        );

        return true;
    }

    function aquire(
        string memory module,
        address implementation,
        bool isImmutable_
    ) external
    returns (bool) {
        _mustBeKeyHolder(module);
        return _aquire(
            module,
            implementation,
            isImmutable_
        );
    }

    function upgrade(
        string memory module,
        address newImplementation
    ) external
    returns (bool) {
        _mustBeKeyHolder(module);
        return _upgrade(
            module,
            newImplementation
        );
    }

    function grantKeyHolder(
        string memory module
    ) external
    returns (bool) {
        _mustBeKeyHolder(module);
        return _grantKeyHolder(module);
    }

    function revokeKeyHolder(
        string memory module
    ) external
    returns (bool) {
        _mustBeKeyHolder(module);
        return _revokeKeyHolder(module);
    }

    function getLatestVersion(
        string memory module
    ) external view
    returns (uint) {
        return _getLatestVersion(module);
    }

    function getLatestImplementation(
        string memory module
    ) external view
    returns (address) {
        return _getLatestImplementation(module);
    }

    function getImplementation(
        string memory module,
        uint version
    ) external view
    returns (address) {
        return _getImplementation(
            module, 
            version
        );
    }

    function mustBeKeyHolder(
        string memory module
    ) external view {
        _mustBeKeyHolder(module);
    }

    function mustBeExistingModule(
        string memory module
    ) external view {
        _mustBeExistingModule(module);
    }

    function mustNotBeImmutable(
        string memory module
    ) external view {
        _mustNotBeImmutable(module);
    }
}