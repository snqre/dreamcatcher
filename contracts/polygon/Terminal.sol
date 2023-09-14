// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import { Pausable } from "contracts/polygon/external/openzeppelin/security/Pausable.sol";

import { EnumerableSet } from "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import { IState } from "contracts/polygon/interfaces/IState.sol";

import { State } from "contracts/polygon/State.sol";

contract Terminal is Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// State Variables

    Dat private _dat;

    address public admin;

    EnumerableSet.AddressSet private _module;

    EnumerableSet.AddressSet private _active;
    EnumerableSet.AddressSet private _locked;
    EnumerableSet.AddressSet private _paused;
    
    mapping(string => uint256) public moduleMapping;

    /// Events

    event Deployed(address indexed msgSender, string indexed module);
    event Upgraded(address indexed msgSender, string indexed module, address indexed newLogic);
    event Rename(address indexed msgSender, string indexed module, string indexed newModule);

    /// Function Modifiers

    modifier onlyAdmin() {
        require(msg.sender == admin, "Terminal: msg.sender != admin");
        _;
    }
    
    /// Struct, Arrays or Enums

    struct Dat { string name; }

    /// Constructor

    constructor(string memory newName) payable {
        admin = msg.sender;
        _dat.name = newName;
        _module.add(address(new State("root", false)));
    }

    /// Plublic View

    function name() public view returns (string memory) {
        return _dat.name;
    }

    function access(string memory module, bytes32 location) public view returns (bytes memory) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.access(location);
    }

    function version(string memory module) public view returns (uint256) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.version();
    }

    function latest(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.latest();
    }

    function previous(string memory module, uint256 index) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.previous(index);
    }

    function empty(string memory module, bytes32 location) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.empty(location);
    }

    function timestamp(string memory module) public view returns (uint64) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.timestamp();
    }

    function locked(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.locked();
    }

    function core(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.core();
    }

    function timerSet(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.timerSet();
    }

    function logic(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.logic();
    }

    function terminal(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return state.terminal();
    }

    function searchByName(string memory module) public view
    returns (
        address terminal_,
        address state_,
        address logic_,
        uint256 version_,
        uint64 timestamp_,
        bool core_,
        bool locked_,
        bool paused_,
        bool timerSet_
    ) {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        return (
            state.terminal(),
            address(state),
            state.logic(),
            state.version(),
            state.timestamp(),
            state.core(),
            state.locked(),
            state.paused(),
            state.timerSet()
        );
    }

    function searchByIndex(uint index) public view
    returns (
        address terminal_,
        address state_,
        address logic_,
        uint256 version_,
        uint64 timestamp_,
        bool core_,
        bool locked_,
        bool paused_,
        bool timerSet_
    ) {
        IState state = IState(_module.at(index));
        return (
            state.terminal(),
            address(state),
            state.logic(),
            state.version(),
            state.timestamp(),
            state.core(),
            state.locked(),
            state.paused(),
            state.timerSet()
        );
    }

    function searcByAccount(address account) public view
    returns (
        address terminal_,
        address state_,
        address logic_,
        uint256 version_,
        uint64 timestamp_,
        bool core_,
        bool locked_,
        bool paused_,
        bool timerSet_
    ) {
        require(_module.contains(account), "State: module not found");
        IState state = IState(account);
        return (
            state.terminal(),
            address(state),
            state.logic(),
            state.version(),
            state.timestamp(),
            state.core(),
            state.locked(),
            state.paused(),
            state.timerSet()
        );
    }

    function count() public view returns (uint256) {
        return _module.length();
    }

    function deploy(string memory module, bool core_) public onlyAdmin() {
        _reqNotInUse(module);
        _module.add(address(new State(module, core_)));
        moduleMapping[module] = _module.length() - 1;
        _active.add(_module.at(moduleMapping[module]));
        emit Deployed(msg.sender, module);
    }

    function upgrade(string memory module, address newLogic) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.upgrade(newLogic);
        emit Upgraded(msg.sender, module, newLogic);
    }

    function rename(string memory module, string memory newModule) public onlyAdmin() {
        _reqInUse(module);
        _reqNotInUse(newModule);
        moduleMapping[newModule] = moduleMapping[module];
        moduleMapping[module] = 0;
        IState state = IState(_module.at(moduleMapping[module]));
        state.update(newModule);
        emit Rename(msg.sender, module, newModule);
    }

    function lock(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.lock();
        _active.remove(_module.at(moduleMapping[module]));
        _locked.add(_module.at(moduleMapping[module]));
    }

    function pause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.pause();
        _paused.add(_module.at(moduleMapping[module]));
    }

    function unpause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.unpause();
        _paused.remove(_module.at(moduleMapping[module]));
    }

    function timer(string memory module, uint64 duration) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.timer(duration);
    }

    function updateTerminal(string memory newName) public onlyAdmin() {
        _dat.name = newName;
    }

    function _reqNotInUse(string memory module) private view {
        require(moduleMapping[module] == 0, "Terminal: module != 0");
    }

    function _reqInUse(string memory module) private view {
        require(moduleMapping[module] != 0, "Terminal: module == 0");
    }
}