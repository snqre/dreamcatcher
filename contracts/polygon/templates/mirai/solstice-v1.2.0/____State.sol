// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/templates/mirai/solstice-v1.2.0/__SharedDeclarations.sol";

interface ____IState {
    function setLogic(address logic_) external;
    function setSettings(
        uint create, 
        uint contribute, 
        uint withdraw, 
        uint update, 
        uint collatTScheduleDuration
    ) external;

    function getSettings() external view returns (uint, uint, uint, uint, uint);
    function setPool(
        uint id, 
        string memory name, 
        string memory description, 
        address creator, 
        EnumerableSet.AddressSet admins, 
        EnumerableSet.AddressSet managers, 
        EnumerableSet.AddressSet contracts, 
        EnumerableSet.UintSet amounts, 
        uint balance, 
        EnumerableSet.AddressSet whitelist, 
        EnumerableSet.AddressSet participants, 
        __SharedDeclarations.PoolState state
    ) external;

    function getPool(uint id) external view returns (
        string memory, 
        string memory, 
        address, 
        EnumerableSet.AddressSet, 
        EnumerableSet.AddressSet, 
        EnumerableSet.AddressSet, 
        EnumerableSet.AddressSet, 
        uint, 
        EnumerableSet.AddressSet, 
        EnumerableSet.AddressSet, 
        __SharedDeclarations.PoolState
    );

    function getPoolsLength() external view returns (uint);

    event LogicStateChanged(address logic);
    event SettingsStateChanged(
        uint create,
        uint contribute,
        uint withdraw,
        uint update,
        uint collatTScheduleDuration
    );
    event PoolStateChanged(
        uint id,
        string name, 
        string description, 
        address creator, 
        EnumerableSet.AddressSet admins, 
        EnumerableSet.AddressSet managers, 
        EnumerableSet.AddressSet contracts, 
        EnumerableSet.UintSet amounts, 
        uint balance, 
        EnumerableSet.AddressSet whitelist, 
        EnumerableSet.AddressSet participants, 
        __SharedDeclarations.PoolState state
    );
}

contract ____State is ____IState, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    address public logic;
    __SharedDeclarations.Settings private _settings;
    __SharedDeclarations.Pool[] private _pools;

    constructor(address logic_) 
        Ownable(msg.sender) {
        logic = logic_;
    }

    function setLogic(address logic_)
        public 
        onlyOwner {
        logic = logic_;
        emit LogicStateChanged(logic);
    }

    function setSettings(
        uint create,
        uint contribute,
        uint withdraw,
        uint update,
        uint collatTScheduleDuration
        ) public
        onlyOwner {
        _settings.fee.create = create;
        _settings.fee.contribute = contribute;
        _settings.fee.withdraw = withdraw;
        _settings.fee.update = update;
        _settings.collatTScheduleDuration = collatTScheduleDuration;
        emit SettingsStateChanged(
            create, 
            contribute, 
            withdraw, 
            update, 
            collatTScheduleDuration
        );
    }

    function getSettings()
        public view
        returns (uint, uint, uint, uint, uint) {
        return (
            _settings.fee.create, 
            _settings.fee.contribute, 
            _settings.fee.withdraw, 
            _settings.fee.update
        );
    }

    function setPool(
        uint id, 
        string memory name, 
        string memory description, 
        address creator, 
        EnumerableSet.AddressSet admins, 
        EnumerableSet.AddressSet managers, 
        EnumerableSet.AddressSet contracts, 
        EnumerableSet.UintSet amounts, 
        uint balance, 
        EnumerableSet.AddressSet whitelist, 
        EnumerableSet.AddressSet participants, 
        __SharedDeclarations.PoolState state
        ) public
        onlyOwner {
        Pool storage pool = _pools[id];
        pool.name = name;
        pool.description = description;
        pool.creator = creator;
        pool.admins = admins;
        pool.managers = managers;
        pool.contracts = contracts;
        pool.amounts = amounts;
        pool.balance = balance;
        pool.whitelist = whitelist;
        pool.participants = participants;
        pool.state = state;
        emit PoolStateChanged(
            id, 
            name, 
            description, 
            creator, 
            admins, 
            managers, 
            contracts, 
            amounts, 
            balance, 
            whitelist, 
            participants, 
            state
        );
    }

    function push() 
        public {
        _pools.push();
    }

    function getPool(uint id)
        public view
        returns (
            string memory, 
            string memory, 
            address, 
            EnumerableSet.AddressSet, 
            EnumerableSet.AddressSet, 
            EnumerableSet.AddressSet, 
            EnumerableSet.AddressSet, 
            uint, 
            EnumerableSet.AddressSet, 
            EnumerableSet.AddressSet, 
            __SharedDeclarations.PoolState
        ) {
        Pool storage pool = _pools[id];
        return (
            pool.name, 
            pool.description, 
            pool.creator, 
            pool.admins, 
            pool.managers, 
            pool.contracts, 
            pool.amounts, 
            pool.balance, 
            pool.whitelist, 
            pool.participants, 
            pool.state
        );
    }

    function getPoolsLength()
        public view
        returns (uint) {
        return _pools.length;
    }
}