// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/templates/modular-upgradeable/controller/Controller.sol";
import "contracts/polygon/projects/dreamcatcher/tokens/DreamToken.sol";
import "contracts/polygon/projects/dreamcatcher/tokens/EmberToken.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";

contract Dreamcatcher is Hub {
    Controller controller;
    DreamToken dreamToken;
    EmberToken emberToken;

    constructor()
        Hub() {
        dreamToken = new DreamToken();
        emberToken = new EmberToken();
        controller = new Controller(address(this), address(dreamToken));
        
        grant(address(controller), address(controller), "queueProposal", __Validator.Class(2), 0, 0, 0);
        grant(address(controller), address(controller), "queueBatchProposal", __Validator.Class(2), 0, 0, 0);
        
    }
}