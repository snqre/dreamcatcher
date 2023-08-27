// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/__Solstice.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/__SharedDeclarations.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/____State.sol";

contract Solstice {
    using EnumerableSet for EnumerableSet.AddressSet;

    ____IState state;

    modifier onlyAdmin(uint id) {
        _onlyAdmin(id);
        _;
    }

    modifier onlyManager(uint id) {
        _onlyManager(id);
        _;
    }

    constructor(address state_) {
        state = ____IState(state_);
    }

    function _onlyAdmin(uint id)
        private view {
        (, , , EnumerableSet.AddressSet admins, , , , , , ,) = state.getPool(id);
        require(admins.contains(msg.sender), "Solstice: caller is not an admin for this pool");
    }

    function _onlyManager(uint id)
        private view {
        (, , , , EnumerableSet.AddressSet managers, , , , , ,) = state.getPool(id);
        require(managers.contains(msg.sender), "Solstice: caller is not a manager for this pool");
    }

    function create(string memory name, string memory description, EnumerableSet.AddressSet admins, EnumerableSet.AddressSet managers) 
        public 
        returns (uint) {
        state.push();
        EnumerableSet.AddressSet emptyAddressSet;
        EnumerableSet.UintSet emptyUintSet;
        state.setPool(
            state.getPoolsLength() - 1, 
            name, 
            description, 
            msg.sender, 
            admins, 
            managers, 
            emptyAddressSet, 
            emptyUintSet, 
            0, 
            emptyAddressSet, 
            emptyAddressSet, 
            __SharedDeclarations.PoolState.UNPAUSED
        );
        return state.getPoolsLength() - 1;
    }

    function setName(uint id, string memory name)
        public
        onlyAdmin(id) {
        ( , string memory description, address creator, EnumerableSet.AddressSet admins, EnumerableSet.AddressSet managers, EnumerableSet.AddressSet contracts, EnumerableSet.UintSet amounts, uint balance, EnumerableSet.AddressSet whitelist, EnumerableSet.AddressSet participants, __SharedDeclarations.PoolState state_) = state.getPool(id);
        state.setPool(id, name, description, creator, admins, managers, contracts, amounts, balance, whitelist, participants, state_);
    }

    
}