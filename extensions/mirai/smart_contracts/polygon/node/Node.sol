// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "deps/openzeppelin/access/Ownable.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";

contract Node is Ownable {
    ModuleManager public moduleManager;
    
    constructor(address owner) Ownable(owner) {
        moduleManager = new ModuleManager();
        moduleManager.create(
            "node",
            address(this)
        );
    }

    function _connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version /// input zero for latest implementation.
    ) internal virtual
    onlyOwner
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

    /// OWNER COMMANDS
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