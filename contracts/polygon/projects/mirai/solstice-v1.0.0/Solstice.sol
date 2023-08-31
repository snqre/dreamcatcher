// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/____Storage.sol";
import "contracts/polygon/projects/mirai/solstice-v1.0.0/__Encoder.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

contract ____Solstice is ____Storage {
    constructor()
        ____Storage() {}
}

contract Solstice {
    using EnumerableSet for EnumerableSet.AddressSet;

    ____IStorage public db;

    constructor(address db_) {
        db = ____IStorage(db_);
        db.setUintStorage(__Encoder.encode("gasCreate"), 1 ether);
        db.setUintStorage(encode("gasContribute"), 1 wei);
        db.setUintStorage(encode("gasWithdraw"), 1 wei);
        db.setUintStorage(encode("gasSwap"), 7 wei);
        db.setUintStorage(encode("gasUpdate"), 2 wei);
    }
}