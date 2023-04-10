pragma solidity ^0.8.0;

contract State {
    // TOKEN
    string internal name;
    string internal symbol;
    uint8 internal decimals;
    uint256 internal maxSupply;
    uint256 internal totalSupply;
    uint256 internal totalVested;
    uint256 internal totalStaked;

    mapping(address => uint256) internal balances;
    mapping(address => uint256) internal vested;
    mapping(address => uint256) internal staked;
    mapping(address => uint256) internal votes;

    mapping(address => bool) internal isAdmin;

    mapping(address => mapping(address => uint256)) allowed;

    // TOKEN STATE
    bool internal isTransferable;
    bool internal isPaused;
    bool internal isMintable;
    bool internal isBurnable;

    // GOVERNANCE
    uint256 internal requiredQuorum;
    uint256 internal votingDelay;
    uint256 internal votingPeriod;
}
