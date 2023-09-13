// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

contract State {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    address public admin;
    address public logic;

    mapping(bytes32 => bytes) public state;

    EnumerableSet.Bytes32Set private _isNotEmpty;

    EnumerableSet.AddressSet private _logics;

    modifier onlyLogic() {
        require(msg.sender == logic);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    event Update(bytes32 indexed location, bytes indexed data);
    event Upgrade(address indexed newLogic);

    constructor() {
        admin = msg.sender;
        logic = msg.sender;
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

    function empty(bytes32 location) public view returns (bool) {
        bytes memory emptyBytes;
        return keccak256(state[location]) == keccak256(emptyBytes);
    }

    function update(bytes32 location, bytes memory data) public onlyLogic {
        if (_isNotEmpty.contains(location) && empty(location)) { _isNotEmpty.remove(location); }
        if (!_isNotEmpty.contains(location) && !empty(location)) { _isNotEmpty.add(location); }
        state[location] = data;
        emit Update(location, data);
    }

    function wipe() public onlyLogic {
        bytes memory emptyBytes;
        for (uint i = 0; i < _isNotEmpty.length(); i++) {
            update(_isNotEmpty.at(i), emptyBytes);
        }
    }

    function upgrade(address newLogic) public onlyAdmin {
        require(newLogic != address(0), "State: new logic is address zero");
        _logics.add(newLogic);
        logic = newLogic;
        emit Upgrade(newLogic);
    }
}