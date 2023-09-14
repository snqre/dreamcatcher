// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import { Pausable } from "contracts/polygon/external/openzeppelin/security/Pausable.sol";

import { EnumerableSet } from "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import { IState } from "contracts/polygon/interfaces/IState.sol";

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

    constructor(string memory name) payable {
        admin = msg.sender;
        _dat.name = name;
        _module.add(address(new State("root", false)));
    }

    function name() public view returns (string memory) {
        return _dat.name;
    }

    function access(string memory module, bytes32 location) public view returns (bytes memory) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.access(location);
    }

    function version(string memory module) public view returns (uint256) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.version();
    }

    function latest(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.latest();
    }

    function previous(string memory module, uint256 index) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.previous(index);
    }

    function empty(string memory module, bytes32 location) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.empty(location);
    }

    function timestamp(string memory module) public view returns (uint64) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.timestamp();
    }

    function locked(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.locked();
    }

    function core(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.core();
    }

    function timerSet(string memory module) public view returns (bool) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.timerSet();
    }

    function logic(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.logic();
    }

    function terminal(string memory module) public view returns (address) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        return state.terminal();
    }

    function searchByName(string memory module) public view
    returns (
        address terminal,
        address state,
        address logic,
        uint256 version,
        uint64 timestamp,
        bool core,
        bool locked,
        bool paused,
        bool timerSet
    ) {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
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
        address terminal,
        address state,
        address logic,
        uint256 version,
        uint64 timestamp,
        bool core,
        bool locked,
        bool paused,
        bool timerSet
    ) {
        IState state = IState(_module[index]);
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
        address terminal,
        address state,
        address logic,
        uint256 version,
        uint64 timestamp,
        bool core,
        bool locked,
        bool paused,
        bool timerSet
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

    function deploy(string memory module, bool core) public onlyAdmin() {
        _reqNotInUse(module);
        _module.add(address(new State(module, core)));
        moduleMapping[module] = _module.length() - 1;
        _active.add(_module[moduleMapping[module]]);
        emit Deployed(msg.sender, module);
    }

    function upgrade(string memory module, address newLogic) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        state.upgrade(newLogic);
        emit Upgraded(msg.sender, module, newLogic);
    }

    function rename(string memory module, string memory newModule) public onlyAdmin() {
        _reqInUse(module);
        _reqNotInUse(newModule);
        moduleMapping[newModule] = moduleMapping[module];
        moduleMapping[module] = 0;
        IState state = IState(_module[moduleMapping[module]]);
        state.update(nameModule);
        emit Rename(msg.sender, module, newModule);
    }

    function lock(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        state.lock();
        _active.remove(_module[moduleMapping[module]]);
        _locked.add(_module[moduleMapping[module]]);
    }

    function pause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        state.pause();
        _paused.add(_module[moduleMapping[module]]);
    }

    function unpause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
        state.unpause();
        _paused.remove(_module[moduleMapping[module]]);
    }

    function timer(string memory module, uint64 duration) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module[moduleMapping[module]]);
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