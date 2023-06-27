// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/access/AccessControl.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";

interface IDreamcatcher {
    /// GOVERNANCE COMMANDS
    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) public 
    returns (bytes memory);

    event Connect(
        string indexed module,
        string indexed signature,
        bytes indexed args,
        uint version,
        address target,
        bytes response
    );
}

contract Dreamcatcher is IDreamcatcher {
    ModuleManager public moduleManager;

    modifier onlyModule(string memory module) {
        /// only if the name identified is a valid module.
        moduleManager.onlyModule(module);
    }

    modifier onlyGovernance(string memory module) {
        /// only governance authorized can access this function.
        moduleManager.onlyGovernance(module);
        require(
            msg.sender == moduleManager.getLatestImplementation(module),
            "Caller is not a governance module or not the latest implementation of the module."
        );
    }

    constructor() {
        /// using module manager we keep track of any static upgrades.
        moduleManager = new ModuleManager();
        moduleManager.create(
            "dreamcatcher", 
            address(this)
        );

        /// terminal is a governance module which can govern itself therefore it can call itself.
        moduleManager.grantGovernance("dreamcatcher");
    }

    function _connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version /// input zero for latest implementation.
    ) internal virtual
    onlyModule(module) /// must be registered as a module
    onlyGovernance(module) /// must be granted governance authorisation.
    returns (bytes memory) {
        bool success;
        bytes memory response;
        address implementation;
        /// get specific implementation of this module.
        if (version != 0) { 
            target = moduleManager.getImplementation(
                module,
                version
            );
        }
        
        /// get the latest implementation of this module.
        else { target = moduleManager.getLatestImplementation(module); }

        (
            success,
            response
        ) = (implementation).call(
            abi.encodeWithSignature(
                signature, 
                args
            )
        );

        require(
            success,
            "Unable to successfully execute function call."
        );

        emit Connect(
            module, 
            signature, 
            args, 
            version, 
            target, 
            response
        );

        /// return response as bytes.
        return response;
    }

    /// GOVERNANCE COMMANDS
    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) public 
    returns (bytes memory) {
        return _connect(
            module, 
            signature, 
            args, 
            version
        );
    }
}