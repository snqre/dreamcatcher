// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/proxy/Base.sol';

contract Foundation is Base {
    function _delegate(address implementation) internal virtual override {
        // Implementations must not be able to delegate call.
        revert();
    }
}