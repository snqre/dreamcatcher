// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/ITerminalV1.sol";

contract ConsoleTerminalV1 {
    
    /** State Variables. */

    ITerminalV1 public terminal;

    /** Constructor. */

    constructor(address terminal_) {
        
        terminal = ITerminalV1(terminal_);
    }

    /** External View. */

    function owner() external view returns (address) {

        return terminal.owner();
    }

    function paused() external view returns (bool) {

        return terminal.paused();
    }

    /** External. */

    function initialize() external {

        terminal.initialize();
    }

    function upgrade(address implementation) external {

        terminal.upgrade(implementation);
    }

    function renounceOwnership() external {

        terminal.renounceOwnership();
    }

    function transferOwnership(address newOwner) external {

        terminal.transferOwnership(newOwner);
    }

    function pause() external {

        terminal.pause();
    }

    function unpause() external {

        terminal.unpause();
    }

    function deploy(string calldata name) external returns (address) {

        return terminal.deploy(name);
    }

    function upgradeTo(string calldata name, address implementation) external {

        terminal.upgradeTo(name, implementation);
    }

    function pause_(string calldata name) external {

        terminal.pause_(name);
    }

    function unpause_(string calldata name) external {

        terminal.unpause_(name);
    }

    function release(string calldata name) external {

        terminal.release(name);
    }
}