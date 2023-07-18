// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/__Timelock.sol";

contract Timelock {
    __Timelock.Request[] public requests;
    __Timelock.Tracker private _tracker;
    __Timelock.Settings private _settings;
    
    constructor() {
        _settings.timelock = 3600 seconds;
        _settings.timeout = 3600 seconds;
    }
    

}