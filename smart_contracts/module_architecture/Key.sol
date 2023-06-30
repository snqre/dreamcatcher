// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "smart_contracts/module_architecture/ModuleManager.sol";

interface IKey {
    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) external 
    returns (bytes memory);

    event Connected(
        string indexed module,
        string indexed signature,
        bytes indexed args,
        uint version,
        address target,
        bytes response
    );
}

contract Key is IKey {
    ModuleManager internal _moduleManager;
    /// make internal
    modifier onlyModule(string memory module) {
        /// only if name points to a module.
        _moduleManager.onlyModule(module);
        _;
    }

    modifier onlyGovernance(string memory module) {
        /// only governance authorized module.
        _moduleManager.onlyGovernance(module);

        /// do this. custom errors. reduce contract side.
        if () {
            revert NoGovernanceModule();
        }

        require(
            msg.sender == _moduleManager.getLatestImplementation(module),
            "Caller is not a governance module or not the latest implementation of the module."
        );
        _;
    }

    constructor(
        string memory nameOfKey        
    ) {
        /// initialize key as a module.
        _moduleManager = new ModuleManager();
        _moduleManager.aquire(
            nameOfKey, 
            address(this)
        ); 
        
        _moduleManager.grantGovernance(nameOfKey);
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

        emit Connected(
            module, 
            signature, 
            args, 
            version, 
            target, 
            response
        );

        /// returns response as bytes.
        return response;
    }

    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) external 
    returns (bytes memory) {
        return _connect(
            module, 
            signature, 
            args, 
            version
        );
    }

    function getAddressOfModuleManager()
    public view
    returns (address) {
        return address(_moduleManager);
    }
}