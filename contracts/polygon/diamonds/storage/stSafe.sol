// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract stSafe {
    bytes32 internal constant _SAFE = keccak256('node.safe');

    struct StSafe {
        uint requiredThreshold;
        uint numTrustee;
        StSafeRequest[] requests;
        mapping(address => bool) isTrustee;
    }

    struct StSafeRequest {
        address to;
        address tokenOut;
        uint amountOut;
        uint numSigned;
        bool done;
        mapping(address => bool) hasSigned;
    }

    function safe() internal pure virtual returns (StSafe storage s) {
        bytes32 location = _SAFE;
        assembly {
            s.slot := location
        }
    }
}