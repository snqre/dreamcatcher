// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IVotable {
    event VoteCasted(address indexed voter, uint8 indexed side, uint indexed amount);

    function support() external view returns (uint);

    function against() external view returns (uint);

    function abstain() external view returns (uint);

    function quorum() external view returns (uint);

    function threshold() external view returns (uint);
}