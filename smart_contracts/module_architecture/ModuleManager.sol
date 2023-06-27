// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "deps/openzeppelin/access/Ownable.sol";

interface IModuleManager {
    /// OWNER COMMANDS
    function create(
        string memory newModule,
        address newImplementation
    ) external returns (bool);

    function upgrade(
        string memory module,
        address newImplementation
    ) external returns (bool);

    function grantGovernance(string memory module)
    public returns (bool);

    function revokeGovernance(string memory module)
    public returns (bool);

    /// PUBLIC ACCESS
    function getLatestVersion(string memory module)
    external view returns (uint);

    function getLatestImplementation(string memory module)
    external view returns (address);

    function onlyModule(string memory module) external view;
    function onlyGovernance(string memory module) external view;

    event ModuleCreated(
        string indexed newModule,
        address indexed newImplementation
    );

    event ModuleUpgraded(
        string indexed module,
        address indexed newImplementation
    );

    event ModuleDowngraded(
        string indexed module,
        address indexed newImplementation
    );

    /// for granted and revoked governance authorisation.
    event ModuleGrantedGovernance(string indexed module);
    event ModuleRevokedGovernance(string indexed module);
}

contract ModuleManager is IModuleManager, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    uint public numberOfModules;

    mapping(
        string => EnumerableSet.AddressSet implementations
    ) private _implementations;
    mapping(string => bool) isGovernance;
    string[] public modules;

    modifier onlyIfNoExistingModuleMatch(string memory module) {
        /// only if there is no matching module with this name.
        require(
            _implementations[module].length() < 1,
            "Module match found."
        );
        _;
    }

    modifier onlyIfExistingModuleMatch(string memory module) {
        /// only if there is a matching module with this name.
        require(
            _implementations[module].length() > 0,
            "Module match not found."
        );
        _;
    }

    modifier onlyIfNoExistingVersionMatch(
        string memory module,
        uint version
    ) {
        /// only if there is no matching implementation with this version.
        require(
            version > _getLatestVersion(module),
            "Version match found."
        );
        _;
    }

    modifier onlyIfExistingVersionMatch(
        string memory module,
        uint version
    ) {
        /// only if there a matching implementation with this version.
        require(
            version <= _getLatestVersion(module),
            "Version match not found."
        );
        _;
    }

    modifier onlyIfNotDuplicateImplementation(
        string memory module,
        address implementation
    ) {
        /// only if module does not have the same implementation address.
        require(
            !_implementations[module].contains(implementation),
            "Module already has this implementation."
        );
        _;
    }

    constructor(address owner) Ownable(owner) {}

    function _getLatestVersion(string memory module)
    internal view virtual returns (uint) {
        /// return the latest version of a module.
        return _implementations[module].length() - 1;
    }

    function _getLatestImplementation(string memory module)
    internal view virtual returns (address) {
        /// return the latest implementation address of a module.
        uint latestVersion = _getLatestVersion(module);
        return _implementations[module].at(latestVersion);
    }

    function _getImplementation(
        string memory module,
        uint previousVersion
    ) internal view virtual
    onlyIfExistingVersionMatch(
        module, 
        previousVersion
    ) returns (address) {
        /// return the implementation address of a specific version.
        return _implementations[module].at(previousVersion);
    }

    function _create(
        string memory newModule,
        address newImplementation
    ) internal virtual
    onlyIfNoExistingModuleMatch(newModule) 
    returns (bool) {
        /// create an instance of a new module.
        numberOfModules += 1;
        _implementations[newModule].add(newImplementation);

        emit ModuleCreated(
            newModule, 
            newImplementation
        );

        modules.push(newModule);
        return true;
    }

    function _upgrade(
        string memory module,
        address newImplementation
    ) internal virtual
    onlyIfExistingModuleMatch(module)
    returns (bool) {
        /// upgrade implementation of a module.
        _implementations[module].add(newImplementation);

        emit ModuleUpgraded(
            module, 
            newImplementation
        );

        return true;
    }

    function _grantGovernance(string memory module) 
    internal virtual
    returns (bool) {
        isGovernance[module] = true;

        emit ModuleGrantedGovernance(module);
        return true;
    }

    function _revokeGovernance(string memory module)
    internal virtual
    returns (bool) {
        isGovernance[module] = false;

        emit ModuleRevokedGovernance(module);
        return true;
    }

    /// OWNER COMMANDS
    function create(
        string memory newModule,
        address newImplementation
    ) public onlyOwner returns (bool) {
        /// create a new module with a first implementation.
        return _create(
            newModule, 
            newImplementation
        );
    }

    function upgrade(
        string memory module,
        address newImplementation
    ) public onlyOwner returns (bool) {
        /// upgrade existing module with new implementation.
        return _upgrade(
            module, 
            newImplementation
        );
    }

    function grantGovernance(string memory module)
    public onlyOwner returns (bool) {
        return _grantGovernance(module);
    }

    function revokeGovernance(string memory module)
    public onlyOwner returns (bool) {
        return _revokeGovernance(module);
    }

    /// PUBLIC ACCESS
    function getLatestVersion(string memory module)
    public view returns (uint) {
        return _getLatestVersion(module);
    }

    function getLatestImplementation(string memory module)
    public view returns (address) {
        /// will get the latest implementation from the array.
        return _getLatestImplementation(module);
    }

    function getImplementation(
        string memory module,
        uint previousVersion
    ) public view returns (address) {
        /// will get the implementation version from the array.
        return _getImplementation(
            module, 
            previousVersion
        );
    }

    function onlyModule(string memory module)
    public view /// will revert if the module does not match.
    onlyIfExistingModuleMatch(module) {}

    /// previous implementations of the module will not hold governance authorisation.
    function onlyGovernance(string memory module)
    public view {
        /// will revert if the module is not governance class.
        require(
            isGovernance[module],
            "Module does not have governance authorization."
        );
    }
}