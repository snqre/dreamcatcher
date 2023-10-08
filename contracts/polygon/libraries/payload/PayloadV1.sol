// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library PayloadV1 {

    struct Payload {
        address target;
        string signature;
        bytes args;
    }

    function target(Payload memory self) public pure returns (address) {
        return self.target;
    }

    function signature(Payload memory self) public pure returns (string memory) {
        return self.signature;
    }

    function args(Payload memory self) public pure returns (bytes memory) {
        return self.args;
    }

    function execute(Payload memory self) public {

    }

    function setTarget(Payload storage self, address target) public {
        self.target = target;
    }

    function setSignature(Payload storage self, string memory signature) public {
        self.signature = signature;
    }

    function setArgs(Payload storage self, bytes memory args) public {
        self.args = args;
    }
}