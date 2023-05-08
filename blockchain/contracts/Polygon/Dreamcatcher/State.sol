pragma solidity ^0.8.0;

contract State {
    struct Code {
        address main;
    } Code private code;
    address admin;
    struct ElectionSchedule {
        uint256 start;
        uint256 duration;
        uint256 reset;
    } ElectionSchedule private electionSchedule;

    function updateElectionSchedule() public
}