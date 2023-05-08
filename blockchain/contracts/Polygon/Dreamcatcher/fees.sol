pragma solidity ^0.8.0;

/**
* poolCreation: fixed fee charged on founding new Pool with us
* burn: basis point amount of nativeToken burnt on transfer
* bank: basis point amount of nativeToken sent to treasury on transfer
* streaming: basis point amount for our products default can be overriden
 */

interface IFee {
    function _update_(string memory _caption, uint256 _fee) public;
}

contract Fee is IFee {
    address terminal;
    mapping(string => uint256) private stringToUint256;

    event Update(string _caption, uint256 _newFee);

    modifier onlyTerminal() {
        require(msg.sender == terminal || msg.sender == address(this));
        _;
    }

    constructor() {
        // establish connection
        terminal = msg.sender;
        // init
        _update_("poolCreation", 10_000);
        _update_("burn", 0);
        _update_("bank", 0);
        _update_("streaming", 0);
    }

    function _update_(string memory _caption, uint256 _newFee) public onlyTerminal {
        stringToUint256[_caption] = _newFee;
        emit Update(_caption, _newFee);
    }

    function fetch(string memory _caption) public view returns (uint256) {
        return stringToUint256[_caption];
    }

}