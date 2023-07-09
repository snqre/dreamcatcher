// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IModuleManager {
    function getLatestVersion(string memory module)
    external view
    returns (uint);

    function getLatestImplementation(string memory module)
    external view
    returns (address);

    function getImplementation(string memory module, uint version)
    external view
    returns (address);

    /// module-manager-aquire
    function aquire(string memory module, address implementation, bool isImmutable_)
    external
    returns (bool);

    /// module-manager-upgrade
    function upgrade(string memory module, address newImplementation)
    external
    returns (bool);

    event ModuleAquired(string indexed module, address indexed implementation, bool isImmutable_);
    event ModuleUpgraded(string indexed module, address newImplementation);

    error ModuleWasFound(string module);
    error ModuleWasNotFound(string module);
    error VersionWasFound(string module, uint version);
    error VersionWasNotFound(string module, uint version);
    error ImplementationWasFound(string module, address implementation);
    error ModuleIsImmutable(string module);
}

contract ModuleManager is IModuleManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    IAuthenticator public authenticator;
    uint public count;

    mapping(string => EnumerableSet.AddressSet) private _implementations;
    mapping(string => bool) public isImmutable;

    constructor(address addressAuthenticator) {
        authenticator = IAuthenticator(addressAuthenticator);
    }

    /// --------
    /// CHECKERS.
    /// --------

    function _onlyIfModuleWasNotFound(string memory module)
        private view {
        if (_implementations[module].length() != 0) {
            revert ModuleWasFound(module);
        }
    }

    function _onlyIfModuleWasFound(string memory module)
        private view {
        if (_implementations[module].length() == 0) {
            revert ModuleWasNotFound(module);
        }
    }

    function _onlyIfVersionWasNotFound(string memory module, uint version)
        private view {
        if (version <= getLatestVersion(module)) {
            revert VersionWasFound(module, version);
        }
    }

    function _onlyIfVersionWasFound(string memory module, uint version)
        private view {
        if (version > getLatestVersion(module)) {
            revert VersionWasNotFound(module, version);
        }
    }

    function _onlyIfImplementationWasNotFound(string memory module, address implementation)
        private view {
        if (!_implementations[module].contains(implementation)) {
            revert ImplementationWasFound(module, implementation);
        }
    }

    function _onlyIfModuleIsNotImmutable(string memory module)
        private view {
        if (isImmutable[module]) { revert ModuleIsImmutable(module); }
    }

    /// ------
    /// PUBLIC.
    /// ------

    function getLatestVersion(string memory module)
        public view
        returns (uint) {
        _onlyIfModuleWasFound(module);
        return _implementations[module].length() - 1;
    }

    /// this is meant to be used as Interface(getLatestImplementation) - will always point towards the latest address of the module.
    function getLatestImplementation(string memory module)
        public view
        returns (address) {
        _onlyIfModuleWasFound(module);
        return _implementations[module].at(getLatestVersion(module));
    }

    function getImplementation(string memory module, uint version)
        public view
        returns (address) {
        _onlyIfModuleWasFound(module);
        _onlyIfVersionWasFound(module, version);
        return _implementations[module].at(version);
    }

    /// use to add a new module to the ecosystem.
    function aquire(string memory module, address implementation, bool isImmutable_)
        external
        returns (bool) {
        /// check to make sure module is not already being used.
        _onlyIfModuleWasNotFound(module);
        authenticator.authenticate(msg.sender, "module-manager-aquire", true, true);
        count ++;
        _implementations[module].add(implementation);
        isImmutable[module] = isImmutable_;
        emit ModuleAquired(module, implementation, isImmutable_);
        return true;
    }

    function upgrade(string memory module, address newImplementation)
        external
        returns (bool) {
        /// check to make sure module is real.
        _onlyIfModuleWasFound(module);
        _onlyIfModuleIsNotImmutable(module);
        authenticator.authenticate(msg.sender, "module-manager-upgrade", true, true);
        _implementations[module].add(newImplementation);
        emit ModuleUpgraded(module, newImplementation);
        return true;
    }
}
