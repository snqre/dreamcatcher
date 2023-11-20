// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

contract Chrysalis {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Chrysalis_ {
        EnumerableSet.Bytes32Set emblems;
    }
}