pragma solidity ^0.8.0;

interface IState {
    function feeToFoundNewPool() public view returns (uint256);
}

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

    struct Fee {
        uint256 toFoundNewPool;
    } Fee private fee;

    function feeToFoundNewPool() public view returns (uint256) {
        return fee.toFoundNewPool;
    }
}