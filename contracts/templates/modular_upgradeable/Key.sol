// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/templates/modular_upgradeable/ModuleManager.sol";

contract Key {
    ModuleManager private _moduleManager;

    constructor(string memory nameOfKey) {
        _moduleManager = new ModuleManager();
        _moduleManager.aquire(nameOfKey, address(this));
    }

    function _connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) internal virtual returns (bytes memory) {
        if (version != 0) {
            target = _moduleManager.getImplementation(module, version);
        } else {
            target = _moduleManager.getLatestImplementation(module);
        }

        (bool success, bytes memory response) = (target).call(
            abi.encodeWithSignature(signature, args)
        );
        if (!success) {
            revert FailedFunctionCall(target, signature, args, version);
        }

        emit Connected(module, signature, args, version, target, response);
        return response;
    }

    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint version
    ) external returns (bytes memory) {
        return _connect(module, signature, args, version);
    }
}
