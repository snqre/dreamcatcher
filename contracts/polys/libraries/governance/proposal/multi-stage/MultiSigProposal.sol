// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library MultiStageProposal {
    struct Proposal {
        /// Metadata
        string _caption;
        string _message;
        address _creator;
        /// MultiSig
        address[] _signers;
        address[] _signatures;
        uint256 _startTimestampProposal;
        /// Referendum
        mapping(address => bool) _hasVoted;
        uint256 _startTimestamp;
        uint256 _duration;
        uint256 _requiredQuorum;
        address _target;
        bytes _data;
        bool _passed;
        bool _executed;
        bool _isTimed;
        bool _requireCallSuccess;
    }

    
}