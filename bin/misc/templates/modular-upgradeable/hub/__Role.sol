// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/__Validator.sol";

library __Role {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @dev helper functions not in __Validator that take bytes32 directly without encoding with of_ and signature
    /// not the most efficient but we are on a tight schedule, its 1am and this does the job
    /// also polygon gas fees are cheap so we can afford to do this

    function add(EnumerableSet.Bytes32Set storage keys, bytes32 key)
        public {
        keys.add(key);
    }

    function remove(EnumerableSet.Bytes32Set storage keys, bytes32 key)
        public {
        keys.remove(key);
    }

    function addKey(EnumerableSet.Bytes32Set storage keys, __Validator.Data storage data, bytes32 key, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance)
        public {
        add(keys, key);
        data.class = class;
        data.startTimestamp = startTimestamp;
        data.endTimestamp = endTimestamp;
        data.balance = balance;
    }

    function removeKey(EnumerableSet.Bytes32Set storage keys, __Validator.Data storage data, bytes32 key)
        public {
        remove(keys, key);
        data.class = __Validator.Class.DEFAULT;
        data.startTimestamp = 0;
        data.endTimestamp = 0;
        data.balance = 0;
    }
}