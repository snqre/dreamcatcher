// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
import "deps/openzeppelin/access/Ownable.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";

interface IMirai {
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

/// note mirai has a seperate module manager.
contract Mirai is IMirai {
    ModuleManager public moduleManager;

    constructor(address dreamcatcher) {
        moduleManager = new ModuleManager();
        moduleManager.create(
            "mirai",
            address(this)
        );

        /// because seprate module manager.
        moduleManager.create(
            "dreamcatcher",
            dreamcatcher
        );

        moduleManager.grantGovernance("mirai");
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