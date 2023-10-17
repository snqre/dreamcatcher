// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19; /** compiler is latest usable on polygon */

import { Pausable } from "contracts/polygon/external/openzeppelin/security/Pausable.sol";

import { EnumerableSet } from "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
* minimalist implementation of ERC930
* able to set core or lockable
 */
contract State is Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// State Variables

    Dat private _dat;

    address public terminal;
    address public logic;

    bool private _locked;
    bool private _core;
    bool private _timer;
    bool private _timerSet;

    uint64 private _timestamp;

    mapping(bytes32 => bytes) public state;

    EnumerableSet.Bytes32Set private _empty;

    EnumerableSet.AddressSet private _implementations;

    /// Events

    event Stored(address indexed msgSender, bytes32 indexed location, bytes indexed data);

    event Updated(address indexed msgSender, string indexed module);

    event TimerSet(address indexed msgSender, uint64 indexed duration);

    event Upgraded(address indexed msgSender, address indexed newLogic);
    
    event Locked(address indexed msgSender);
    
    event Wiped(address indexed msgSender);

    /// Function Modifiers

    modifier onlyLogic() {
        require(msg.sender == latest(), "State: msg.sender != logic");
        _;
    }

    modifier onlyTerminal() {
        require(msg.sender == terminal, "State: msg.sender != terminal");
        _;
    }

    modifier onlyNotLocked() {
        require(!locked(), "State: permanently locked");
        _;
    }

    modifier onlyNotTimedOut() {
        if (_timer && timerSet()) {
            require(block.timestamp <= timestamp(), "State: permanently locked"); /** noted use of block.timestamp and its vulnerabilities */
        }
        _;
    }

    modifier onlyNotCore() {
        require(!core(), "State: is core");
        _;
    }

    modifier onlyNotTimed() {
        require(timestamp() == 0, "State: is timed");
        _;
    }

    modifier onlyIfTimerNotSet() {
        require(!timerSet(), "State: timer already set");
        _;
    }

    modifier onlyIfNotAddressZero() {
        require(msg.sender != address(0), "State: caller is address zero");
        _;
    }

    /// Struct, Arrays or Enums

    struct Dat { string module; }

    /// Constructor

    /** @param isCore if the state is lockable or can expire */
    constructor(string memory nameModule, bool isCore) payable {
        terminal = msg.sender;
        /** logic starts as address zero which is unable to call any functions */
        _locked = false;
        _core = isCore;
        _timer = false;
        _timerSet = false;
        _timestamp = 0;
        update(nameModule);
    }

    /// External

    /**
    * @dev set a timer and once block.timestamp is over new data will not be able to be stored
    * SHOULD only be able to be called by terminal
    * SHOULD only be able to called if not locked
    * SHOULD only be able to called if not already timed out
    * SHOULD only be able to called if the timer was not set already
    * SHOULD only be able to called if the state is not a core module
    * SHOULD only be able to called if not paused
    * WARNING permanently locks entire contract!
    * SHOULD only be able to be called if caller is not address zero
     */
    function timer(uint64 duration) external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyIfTimerNotSet() onlyNotCore() whenNotPaused() onlyIfNotAddressZero() {
        _timer = true;
        _timerSet = true;
        _timestamp = uint64(block.timestamp); /** noted use of block.timestamp and its potential vulnerabilities */
        /** x = x + y is more gas effective than x += y */
        _timestamp = _timestamp + duration;
        emit TimerSet(msg.sender, duration);
    }

    /**
    * @dev lock the state so new data will not be able to be stored
    * SHOULD only be able to be called by terminal
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not timed
    * SHOULD only be able to be called if timer was not set already
    * SHOULD only be able to be called if the state is not a core module
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
    * WARNING permanently locks entire contract!
     */
    function lock() external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyNotTimed() onlyIfTimerNotSet() onlyNotCore() whenNotPaused() onlyIfNotAddressZero() {
        _locked = true;
        emit Locked(msg.sender);
    }

    /**
    * @dev wipe all data within state mapping
    * SHOULD only be able to be called by current logic address
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
    * SHOULD only be able to called if the state is not a core module
    * note unchecked because if the iteration gets large enough there wont be a enough gas to continue
     */
    function wipe() external onlyLogic() onlyNotLocked() onlyNotTimedOut() whenNotPaused() onlyIfNotAddressZero() onlyNotCore() {
        unchecked {
            bytes memory emptyBytes;
            uint256 len = _empty.length();
            for (uint256 i = 0; i < len; ++i) {
                store(_empty.at(i - 1), emptyBytes);
            }
            emit Wiped(msg.sender);
        }
    }

    /**
    * @dev upgrade logic by giving permission to new logic
    * SHOULD only be able to be called by terminal
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
     */
    function upgrade(address newLogic) external onlyTerminal() onlyNotLocked() onlyNotTimedOut() whenNotPaused() onlyIfNotAddressZero() {
        require(!_implementations.contains(newLogic), "State: previous implementation");
        require(newLogic != address(0), "State: newLogic is address zero");
        _implementations.add(newLogic);
        logic = newLogic;
        emit Upgraded(msg.sender, newLogic);
    }

    function pause() external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyIfNotAddressZero() onlyNotCore() {
        _pause();
        /** @dev event inherited and emited within _pause */
    }

    function unpause() external onlyTerminal() onlyNotLocked() onlyNotTimedOut() onlyIfNotAddressZero() onlyNotCore() {
        _unpause();
        /** @dev event inherited and emitted within _unpause */
    }

    /// External View

    function previous(uint256 index) external view returns (address) {
        return _implementations.at(index);
    }

    function access(bytes32 location) external view returns (bytes memory) {
        return state[location];
    }

    /// Public View

    function module() public view returns (string memory) {
        return _dat.module;
    }

    function version() public view returns (uint256) {
        return _implementations.length();
    }

    function empty(bytes32 location) public view returns (bool) {
        bytes memory emptyBytes;
        return keccak256(state[location]) == keccak256(emptyBytes);
    }

    function timestamp() public view returns (uint64) {
        return _timestamp;
    }

    function locked() public view returns (bool) {
        return _locked;
    }

    function core() public view returns (bool) {
        return _core;
    }

    function timerSet() public view returns (bool) {
        return _timerSet;
    }

    function latest() public view returns (address) {
        return _implementations.at(version() - 1);
    }

    /// Public

    /**
    * @dev store data within state mapping
    * @param location key of where to store the data
    * @param data can store any type of data by converting to bytes
    * SHOULD only be able to be called by current logic address
    * SHOULD only be able to be called if not locked
    * SHOULD only be able to be called if not timed out
    * SHOULD only be able to be called if not paused
    * SHOULD only be able to be called if caller is not address zero
     */
    function store(bytes32 location, bytes memory data) public onlyLogic() onlyNotLocked() onlyNotTimedOut() whenNotPaused() onlyIfNotAddressZero() {
        if (_empty.contains(location) && empty(location)) { _empty.remove(location); }
        if (!_empty.contains(location) && !empty(location)) { _empty.add(location); }
        state[location] = data;
        emit Stored(msg.sender, location, data);
    }

    /** @dev updates module name */
    function update(string memory nameModule) public onlyTerminal() whenNotPaused() onlyIfNotAddressZero() {
        require(!_isSameString(module(), nameModule), "State: same module name");
        _dat.module = nameModule;
        emit Updated(msg.sender, nameModule);
    }

    /// Private Pure

    function _isSameString(string memory stringA, string memory stringB) private pure returns (bool) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }
}