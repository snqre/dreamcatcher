// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    address private nativeToken;
    address private admin;

    struct Candidate {
        address candiate;
        uint256 yes;
        uint256 no;
        uint256 abstain;
    } mapping(uint256=>Candiate) private candidates;
    uint256 private candiatesCount;
    
    /** participation to board require a set amount of stake */
    modifier stake() {
        _;
    }

    event NewCandidate(
        address indexed _candiate
    );

    constructor(
        address _nativeToken
    ) public {
        admin = msg.sender;
        nativeToken = _nativeToken;
    }

    function getCandiate(uint256 _id) public view returns (Candidate) {
        return candidates[_id];
    }

    function participate() public stake returns (bool) {
        candiatesCount += 1;
        candiates[candiatesCount] = Candiate(
            candiate = msg.sender,
            yes = 0,
            no = 0,
            abstain = 
        );
        return true;
    }

    function support(uint256 _id, uint256 _support) public returns (bool) {
        /** candidate */
        candidates[]
        uint256 _valueWei = _value / 10**18;
        uint256 _balance = IERC20(nativeToken).balanceOf(msg.sender);
        uint256 _staked;
        require(_balance >= _valueWei, "Election: insufficient balance");
        return true;
    }

    
}