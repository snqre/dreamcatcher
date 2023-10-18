// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/Foundation.sol";
import "contracts/polygon/abstract/proxy/FoundationImplementation.sol";
import "contracts/polygon/interfaces/proxy/IFoundationImplementation.sol";

contract TerminalDeployer {

    Foundation private _module;
    FoundationImplementation private _implementation;

    constructor() {
        _implementation = new FoundationImplementation();
        _module = new Foundation();
        IFoundationImplementation module = IFoundationImplementation(address(_module));
        module.configure(address(_implementation));
        module.initialize();
        module.transferOwnership(msg.sender);
    }
}