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
        State = new State(

        );
        Token = new ERC20(
            _admin,
            _name,
            _symbol
        );
    }

    function mint() private {

    }

    function burn() private {
        
    }

    function contribute() public returns (bool) {
        // value * supply / balance
    }
}