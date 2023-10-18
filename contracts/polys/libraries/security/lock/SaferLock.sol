// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library SaferLock {
    struct Lock {
        bool _locked;
        uint256 _startTimestamp;
        uint256 _duration;
        bool _isTimed;
        bool _reverseOnCompletion;
        bool _resetOnCompletion;
        bool _onlyDuringTimer;
    }

    
}