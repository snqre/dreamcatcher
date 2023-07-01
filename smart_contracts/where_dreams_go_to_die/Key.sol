// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "smart_contracts/module_architecture/ModuleManager.sol";

interface IKey {
    event Connected(
        string indexed module,
        string indexed signature,
        bytes indexed args,
        uint version,
        address target,
        bytes response
    );

    error UnableToExecuteFunctionCall(
        address target,
        string signature,
        bytes args,
        uint version
    );
}

contract Key is IKey, ModuleManager {
    constructor (
        string memory nameOfKey,
        string memory nameOfKeyHolderModule,
        address implementation
    ) {
        _aquire(
            nameOfKey, 
            address(this),
            true
        );

        _grantKeyHolder(nameOfKey);

        _aquire(
            nameOfKeyHolderModule,
            implementation,
            true
        );
    }

    function _connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) internal virtual
    returns (bytes memory) {
        bool success;
        bytes memory response;
        address implementation;
        address target;

        /// get specific implementation of this module.
        if (version != 0) {
            target = _getImplementation(
                module, 
                version
            );
        }

        /// get the latest implementation of this module.
        else { target = _getLatestImplementation(module); }

        (
            success,
            response
        ) = (implementation).call(
            abi.encodeWithSignature(
                signature, 
                args
            )
        );

        if (!success) {
            revert UnableToExecuteFunctionCall(
                target,
                signature,
                args,
                version
            );
        }

        emit Connected(
            module,
            signature,
            args,
            version,
            target,
            response
        );

        return response;
    }

    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) external
    returns (bytes memory) {
        _mustBeExistingModule(module);
        _mustBeKeyHolder(module);
        return _connect(
            module, 
            signature, 
            args, 
            version
        );
    }
}