pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/Pool/Prototype/ClosedPool/State.sol";
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";
import "smart_contracts/contracts/Polygon/Pool/Prototype/ClosedPool/Logic.sol";

contract Pool {
    State immutable state;
    Logic logic;
    Token token;

    constructor(
        address _manager,
        string memory _tknName,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        State = new State();
        Logic = new Logic();
        Token = new Token();
    }
}