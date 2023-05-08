pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Dreamcatcher/State.sol";
contract Logic {
    State private state;
    constructor() {
        state = new State();
    }
    /** deposit matic */
    function deposit_(uint256 _value) private payable returns (bool) {
        address payable _recipient = payable(address(state));
        _recipient.transfer(_value * 10**18);
        return true;
    }
    /** withdraw matic */
    function withdraw_(address _to, uint256 _value) private returns (bool) {
        state.withdraw(_to, _value);
    }
}