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

    // admins
    modifier onlyAdmin(address account) {
        require(isAdmin[account], "onlyAdmin");
        _;
    }

    function toggleAdmin(address account) internal returns (bool) {
        if (isAdmin[account] == false) {isAdmin[account] = true;}
        else if (State.isAdmin[account] == true) {isAdmin[account] = false;}
    }

    modifier checkIsTransferable() {
        require(isTransferable == true);
        _;
    }

    modifier checkIsPaused() {
        require(isPaused == false);
        _;
    }

    modifier checkIsMintable() {
        require(isMintable == true);
        _;
    }

    modifier checkIsBurnable() {
        require(isBurnable == true);
        _;
    }

    modifier checkConduitIsPaused() {
        require(conduitIsPaused == false);
        _;
    }
}
