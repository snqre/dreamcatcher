pragma solidity ^0.8.0;

/** basically the only thing this does it keep a database */
interface IState {
    function feeToFoundNewPool() public view returns (uint256);
}

contract State {
    address terminal;
    
    mapping(string => uint256) private stringToUint256;
    
    modifier onlyTerminal() {
        require(msg.sender == terminal || msg.sender == address(this));
        _;
    }

    constructor() {
        
    }
}