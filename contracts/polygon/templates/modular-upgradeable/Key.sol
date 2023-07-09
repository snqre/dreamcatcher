// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";
import "contracts/polygon/templates/modular-upgradeable/ModuleManager.sol";

interface IKey {
    event Connected(address indexed target, string indexed signature, bytes indexed args);
    event ModuledCreated(string indexed module, address indexed implementation, string[] indexed keys);
    event ModuleUpgraded(string indexed module, address indexed newImplementation, string[] indexed keys);

    error UnableToMakeCall();
}

contract Key is IKey {
    Authenticator public authenticator;
    ModuleManager public moduleManager;

    constructor() {
        /// on deployment authenticator grants its keys to deployer.
        authenticator = new Authenticator();
        moduleManager = new ModuleManager(address(authenticator));

        /// grant keys to access module manager.
        authenticator.grantKey(address(this), "module-manager-aquire");
        authenticator.grantKey(address(this), "module-manager-upgrade");

        /// grant keys to itself.
        authenticator.grantKey(address(this), "key-create-new-module");
        authenticator.grantKey(address(this), "key-upgrade-module");
    }

    /** IT IS MORE IDEAL TO CREATE MODULES THROUGH THIS FUNCTION.
    * @param module is module name.
    * @param implementation is the first contract with the module's first implementation.
    * @param keys is access to all the contract's locked  functions as keys.
    
    automatically grants access to new module's keys to key - same with upgrade function.
     */
    function createNewModule(string memory module, address implementation, string[] memory keys)
        public
        returns (bool) {
        authenticator.authenticate(msg.sender, "key-create-new-module", true, true);
        moduleManager.aquire(module, implementation);
        for (uint i = 0; i < keys.length; i ++) {
            authenticator.grantKey(address(this), keys[i]);
        }

        emit ModuledCreated(module, implementation, keys);
        return true;
    }

    function upgradeModule(string memory module, address newImplementation, string[] memory keys)
        public
        returns (bool) {
        authenticator.authenticate(msg.sender, "key-upgrade-module", true, true);
        moduleManager.upgrade(module, newImplementation);
        for (uint i = 0; i < keys.length; i ++) {
            /// this will duplicate the same key if the other contract has identical keys - please refer to naming convention.
            authenticator.grantKey(address(this), keys[i]);
        }

        emit ModuleUpgraded(module, newImplementation, keys);
        return true;
    }

    /// if everything is working this should be able to access all functions from new modules and all the ecosystem.
    function connect(string memory module, string memory signature, bytes memory args, uint version)
        external
        returns (bytes memory) {
        authenticator.authenticate(msg.sender, "key-connect", true, true);
        address target;
        if (version != 0) { target = moduleManager.getImplementation(module, version); }
        else { target = moduleManager.getLatestImplementation(module); }

        (bool success, bytes memory response) = (target).call(abi.encodeWithSignature(signature, args));
        if (!success) { revert UnableToMakeCall(); }

        emit Connected(target, signature, args);
        return response;
    }
}