// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/**

    The "__Encoder" library provides a set of utility functions 
    to encode various data types into a unique identifier represented as a 
    bytes32 value. The "encode" function takes a string as input 
    and returns its keccak256 hash as a bytes32 value. Similarly, 
    the "encodeWithIteration" and "encodeWithAccount" functions concatenate a uint 
    or an address with the input string before hashing. 
    
    The "encodeWithIterationAndAccount" function combines both a uint and an address 
    with the input string before hashing. Additionally, the library includes the "encodeKey" 
    function that takes an address and a string (representing a signature) and returns their 
    combined hash as a bytes32 identifier. These encoding functions offer a convenient way to 
    generate unique and secure identifiers for various use cases in smart contract development, 
    such as data storage, access control, and mapping.

 */

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

    function encodeWithAccount(string memory string_, address account)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(string_, account));
    }

    function encodeWithRole(string memory string_, string memory role)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(string_, role));
    }

    function encodeWithIterationAndAccount(string memory string_, uint index, address account)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(string_, index, account));
    }

    function encodeKey(address of_, string memory signature)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(of_, signature));
    }

    function encodeKeyPropertyWithAccount(address account, string memory string_, address of_, string memory signature)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(account, string_, of_, signature));
    }

    function encodeKeyPropertyWithRole(string memory role, string memory string_, address of_, string memory signature)
        public pure
        returns (bytes32) {
        return keccak256(abi.encode(role, string_, of_, signature));
    }
}