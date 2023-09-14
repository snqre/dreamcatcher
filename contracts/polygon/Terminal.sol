// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import { Pausable } from "contracts/polygon/external/openzeppelin/security/Pausable.sol";

import { EnumerableSet } from "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import { IState } from "contracts/polygon/interfaces/IState.sol";

import { State } from "contracts/polygon/State.sol";

/**
* control routers, upgrades, all in one place
* call Terminal to find the up to date location of all other modules and use the appropriate interface
* with this mechanism old implementations cannot store information within each router hence they will not be able to be used
 */
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

    event RouterDeployed(address indexed msgSender, string indexed module);

    event RouterUpgraded(address indexed msgSender, string indexed module, address indexed newLogic);

    event RouterRenamed(address indexed msgSender, string indexed module, string indexed newModule);

    event RouterLocked(address indexed msgSender, string indexed module);

    event RouterTimerSet(address indexed msgSender, string indexed module, uint64 indexed duration);

    event RouterPaused(address indexed msgSender, string indexed module);

    event RouterUnpaused(address indexed msgSender, string indexed module);

    event OwnershipTransferred(address indexed msgSender, address indexed newOwner);

    event Updated(address indexed msgSender, string indexed newName);
    
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

    /** @dev lookup routers by module name */
    function searchByName(string memory module) public view
    returns (
        string memory module_,
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
            state.module(),
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

    /** @dev look up routers by module index */
    function searchByIndex(uint index) public view
    returns (
        string memory module,
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
            state.module(),
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

    /** @dev look up routers by address */
    function searchByAccount(address account) public view
    returns (
        string memory module,
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
            state.module(),
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

    /** @dev this is a monstruousity */
    function arrayActive() public view returns (string[10000000] memory) {
        address[] memory addrActive = _active.values();
        string[10000000] memory active;
        for (uint i = 0; i < addrActive.length; i++) {
            (string memory module, , , , , , , , ,) = searchByAccount(addrActive[i]);
            active[i] = module;
        }
        return active;
    }

    /** @dev number of routrs deployed without root router */
    function count() public view returns (uint256) {
        return _module.length() - 1;
    }

    /// Public

    /**
    * @dev deploys a State.sol contract (see State.sol) which acts as a router and ERC930 implementation
    * @param core_ core router cannot be paused, unpaused, locked, or set to exipire
     */
    function deploy(string memory module, bool core_) public onlyAdmin() {
        _reqNotInUse(module);
        _module.add(address(new State(module, core_)));
        moduleMapping[module] = _module.length() - 1;
        _active.add(_module.at(moduleMapping[module]));
        emit RouterDeployed(msg.sender, module);
    }

    function upgrade(string memory module, address newLogic) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.upgrade(newLogic);
        emit RouterUpgraded(msg.sender, module, newLogic);
    }

    function rename(string memory module, string memory newModule) public onlyAdmin() {
        _reqInUse(module);
        _reqNotInUse(newModule);
        moduleMapping[newModule] = moduleMapping[module];
        moduleMapping[module] = 0;
        IState state = IState(_module.at(moduleMapping[module]));
        state.update(newModule);
        emit RouterRenamed(msg.sender, module, newModule);
    }

    /** @dev WARNING permanently locks non core router which will not be able to store any more data */
    function lock(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.lock();
        _active.remove(_module.at(moduleMapping[module]));
        _locked.add(_module.at(moduleMapping[module]));
        emit RouterLocked(msg.sender, module);
    }

    function pause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.pause();
        _paused.add(_module.at(moduleMapping[module]));
        emit RouterPaused(msg.sender, module);
    }

    function unpause(string memory module) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.unpause();
        _paused.remove(_module.at(moduleMapping[module]));
        emit RouterUnpaused(msg.sender, module);
    }

    /** @dev set a timer at which the non core router will stop storing data */
    function timer(string memory module, uint64 duration) public onlyAdmin() {
        _reqInUse(module);
        IState state = IState(_module.at(moduleMapping[module]));
        state.timer(duration);
        emit RouterTimerSet(msg.sender, module, duration);
    }

    /** update terminal name */
    function update(string memory newName) public onlyAdmin() {
        _dat.name = newName;
        emit Updated(msg.sender, newName);
    }

    function transferOwnership(address account) public onlyAdmin() {
        admin = account;
        emit OwnershipTransferred(msg.sender, account);
    }

    /// Private View

    function _reqNotInUse(string memory module) private view {
        require(moduleMapping[module] == 0, "Terminal: module != 0");
    }

    function _reqInUse(string memory module) private view {
        require(moduleMapping[module] != 0, "Terminal: module == 0");
    }
}