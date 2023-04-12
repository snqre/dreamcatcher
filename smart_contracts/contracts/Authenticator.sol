// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/contracts/state/State.sol";

contract Authenticator is State {
    bool private locked;
    modifier reentrancyLock() {
        require(!locked, "Anti-Reentrancy Lock");
        locked = true;
        _;
        locked = false;
    }
}
