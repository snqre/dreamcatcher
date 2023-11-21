// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EncodeFunctionCall {
    function encodeWithSignature(uint value) public virtual returns (bytes memory) {
        return abi.encodeWithSignature("____setMultiSigDuration(uint256)", value);
    }
}