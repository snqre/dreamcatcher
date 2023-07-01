// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "smart_contracts/module_architecture/ModuleManager.sol";

interface IKey {
    error FailedFunctionCall(address target, string signature, bytes args, uint version);

    event Connected(string indexed module, string indexed signature, bytes indexed args, uint version, address target, bytes response);
}

contract Key is IKey {
    ModuleManager private _moduleManager;

    constructor(string memory nameOfKey) {
        _moduleManager = new ModuleManager();
        _moduleManager.aquire(nameOfKey, address(this));
    }

    /// call function that can access target modules.
    function _connect(string memory module, string memory signature, bytes memory args, uint version)
    internal virtual 
    returns (bytes memory) {
        /// get target.
        if (version != 0) {target = _moduleManager.getImplementation(module, version); }
        else { target = _moduleManager.getLatestImplementation(module); }

        /// call target.
        (bool success, bytes memory response) = (target).call(abi.encodeWithSignature(signature, args));
        if (!success) { revert FailedFunctionCall(target, signature, args, version); }

        /// get response and emit event.
        emit Connected(module, signature, args, version, target, response);
        return response;
    }

    function connect(string memory module, string memory signature, bytes memory args, uint version)
    external
    returns (bytes memory) {
        return _connect(module, signature, args, version);
    }
}