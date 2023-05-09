// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

contract State00 {
    struct InitialFundingRound {
        uint256 duration;
        uint256 start;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool transferable;
    } InitialFundingRound internal initialFundingRound;
}

contract State01 {
    struct My {
        Token nativeToken;
        string name;
        string description;
        address creator;
    } My internal my;
}

contract State02 {
    struct Settings {
        bool governance;
    } Settings internal settings;
}

contract State03 {
    struct Proposal {
        uint256 id;
        address proposer;
        string caption;
        string description;
        uint256 yes;
        uint256 no;
        uint256 abstain;
        bool successful;
        bool executed;
    } mapping(uint256 =>  Proposal) internal proposal;
}

contract State04 {
    mapping(address => bool) internal whitelist;
}

contract State05 {
    event Contribution(address indexed _from, uint256 _value, uint256 _mint);
    event Withdrawal(address indexed _from, uint256 _burn, uint256 _value);
}

contract State is State00, State01, State02, State03, State04, State05 {
 
}
