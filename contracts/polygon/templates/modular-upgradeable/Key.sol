// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";
import "contracts/polygon/templates/modular-upgradeable/ModuleManager.sol";
import "contracts/polygon/deps/openzeppelin/access/AccessControl.sol";

interface IKey {
    event Connected(string indexed module, string indexed signature, bytes indexed args, uint version, address target, bytes response);

    error FailedFunctionCall();
    error ModuleDoesNotHaveGovernancePermission(string module);

    function connect(string memory module, string memory signature, bytes memory args, uint version) external returns (bytes memory);
}

contract Key is IKey {
    Authenticator public authenticator;
    ModuleManager public moduleManager;

    constructor(string memory nameOfKey, address governor) {
        moduleManager = new ModuleManager(address(this));
        moduleManager.aquire(nameOfKey, address(this));
        moduleManager.aquire("governor", governor);

        authenticator = new Authenticator(address(this));

    }

    function connect(string memory module, string memory signature, bytes memory args, uint version)
    external
    returns (bytes memory) {
        authenticator.authenticate(msg.sender, 9);

        address target;
        if (version != 0) { target = moduleManager.getImplementation(module, version); }
        else { target = moduleManager.getLatestImplementation(module); }

        (bool success, bytes memory response) = (target).call(abi.encodeWithSignature(signature, args));
        require(success, "FAILED_FUNCTION_CALL");

        emit Connected(module, signature, args, version, target, response);
        return response;
    }
}
