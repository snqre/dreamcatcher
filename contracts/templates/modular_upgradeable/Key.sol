// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/templates/modular_upgradeable/ModuleManager.sol";

contract Key {
    ModuleManager public moduleManager;

    event Connected(
        string indexed module,
        string indexed signature,
        bytes indexed args,
        uint256 version,
        address target,
        bytes response
    );

    constructor(string memory nameOfKey, address governor) {
        moduleManager = new ModuleManager(address(this));
        moduleManager.aquire(nameOfKey, address(this));
        moduleManager.aquire("governor", governor);
    }

    function _connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint256 version
    ) internal virtual returns (bytes memory) {
        bool hasGovernancePermission = moduleManager.hasGovernancePermission_(
            module
        );
        require(
            hasGovernancePermission,
            "Key: Module does not have governance permission or is not its latest implementation."
        );

        address target;
        if (version != 0) {
            target = moduleManager.getImplementation(module, version);
        } else {
            target = moduleManager.getLatestImplementation(module);
        }

        (bool success, bytes memory response) = (target).call(
            abi.encodeWithSignature(signature, args)
        );

        require(success, "Key: Failed function call.");

        emit Connected(module, signature, args, version, target, response);
        return response;
    }

    function connect(
        string memory module,
        string memory signature,
        bytes memory args,
        uint256 version
    ) external returns (bytes memory) {
        return _connect(module, signature, args, version);
    }
}
