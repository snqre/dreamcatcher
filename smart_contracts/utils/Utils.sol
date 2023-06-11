// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
    function convertToWei(uint value) internal pure returns (uint) {
        return value * 10**18;
    }

    function strToByte(string memory string_) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(string_));
    }

    function byteToStr(bytes32 value) internal pure returns (string memory) {
        bytes memory bytesValue = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            bytesValue[i] = value[i];
        }

        return string(bytesValue);
    }

    function amountToMint(uint v, uint s, uint b) internal pure returns (uint) {
        // v: value
        // s: suppl
        // b: balan
        
        require(v >= convertToWei(1));
        require(s >= convertToWei(1));
        require(b >= convertToWei(1));

        return ((v * s) / b);
    }

    function valueToSend(uint v, uint s, uint b) internal pure returns (uint) {
        // v: amoun
        // s: suppl
        // b: balan

        require(v >= convertToWei(1));
        require(s >= convertToWei(1));
        require(b >= convertToWei(1));

        return ((v * b) / s);
    }
}