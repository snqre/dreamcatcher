// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

contract State {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Meta { string module; }

    Meta private _meta;

    address public admin;
    address public logic;

    bool private _lock;

    mapping(bytes32 => bytes) public state;

    EnumerableSet.Bytes32Set private _isNotEmpty;

    EnumerableSet.AddressSet private _logics;

    modifier onlyLogic() {
        _onlyLogic();
        _;
    }

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier whenNotLocked() {
        _whenNotLocked();
        _;
    }

    event Store(bytes32 indexed location, bytes indexed data);
    event Update(string indexed module);
    event Upgrade(address indexed newLogic);
    event Lock();
    event Wipe();

    constructor(string memory module_) {
        admin = msg.sender;
        logic = msg.sender;
        update(module_);
    }

    function module() public view returns (string memory) {
        return _meta.module;
    }

    function access(bytes32 location) public view returns (bytes memory) {
        return state[location];
    }

    function version() public view returns (uint256) {
        return _logics.length();
    }

    function latest() public view returns (address) {
        return _logics.at(version() - 1);
    }

    function previous(uint index) public view returns (address) {
        return _logics.at(index);
    }

    function empty(bytes32 location) public view returns (bool) {
        bytes memory emptyBytes;
        return keccak256(state[location]) == keccak256(emptyBytes);
    }

    function store(bytes32 location, bytes memory data) public onlyLogic whenNotLocked {
        if (_isNotEmpty.contains(location) && empty(location)) { _isNotEmpty.remove(location); }
        if (!_isNotEmpty.contains(location) && !empty(location)) { _isNotEmpty.add(location); }
        state[location] = data;
        emit Store(location, data);
    }

    function wipe() public onlyLogic whenNotLocked {
        bytes memory emptyBytes;
        for (uint256 i = 0; i < _isNotEmpty.length(); i++) {
            store(_isNotEmpty.at(i), emptyBytes);
        }
        emit Wipe();
    }

    function upgrade(address newLogic) public onlyAdmin {
        require(newLogic != address(0), "State: new logic is address zero");
        _logics.add(newLogic);
        logic = newLogic;
        emit Upgrade(newLogic);
    }

    function update(string memory module_) public onlyAdmin {
        _meta.module = module_;
        emit Update(module_);
    }

    function lock() public onlyAdmin whenNotLocked {
        _lock = true;
        emit Lock();
    }

    function _onlyLogic() private view {
        require(msg.sender == logic, "State: msg.sender != logic");
    }

    function _onlyAdmin() private view {
        require(msg.sender == admin, "State: msg.sender != admin");
    }

    function _whenNotLocked() private view {
        require(!_lock, "State: permanently locked");
    }
}