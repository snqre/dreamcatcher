pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Dreamcatcher/Authenticator.sol";
import "blockchain/contracts/Polygon/Dreamcatcher/Treasury.sol";
contract Logic {
    struct ElectionSchedule {
        uint256 start;
        uint256 duration;
        uint256 reset;
    } ElectionSchedule private electionSchedule;

    Treasury private treasury;
    Authenticator private authenticator;
    constructor() {
        treasury = new Treasury();
        authenticator = new Authenticator();

        /** set up election schedule */
        electionSchedule.start = block.timestamp;
        electionSchedule.duration = 48 weeks;
    }

    function election() public returns (bool) {
        require(
            
        );
    }

}