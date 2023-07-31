// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library __Encoder {
    function encode(string memory string_)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(string_));
    }

    function encodeWithIteration(string memory string_, uint index)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(string_, index));
    }

    function encodeWithIterationAndAccount(string memory string_, uint index, address account)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(string_, index, account));
    }
}