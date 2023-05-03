pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/Token.sol";

/**
* seams like the main errors encountered on testnet are permissions
 */
contract Pool {
    Token nativeToken;

    constructor (
        string memory _tknName,
        string memory _tknSymbol,
        uint256 _tknInitialSupply
    ) payable {
        require(msg.value >= 0.01 * 10**18, "Pool: msg.value < 1 * 10**18");
        require(_tknInitialSupply * 10**18 >= 1 * 10**18, "Pool: _tknInitialSupply < 1 * 10**18");
        address _creator = msg.sender;
        nativeToken = new Token(_tknName, _tknSymbol);
        nativeToken.mint(_creator, _tknInitialSupply);
    }
    
    // ** are we adding value before checking balance?
    function contribute() public payable returns (bool) {
        uint256 _valueWei = msg.value;
        uint256 _supplyWei = nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance - _valueWei;
        uint256 _amountToMint = (_valueWei * _supplyWei) / _balanceWei;

        require(
            _valueWei > 0 * 10**18 &&
            _supplyWei > 0 * 10**18 &&
            _balanceWei > 0 * 10**18
        );

        nativeToken.mint(msg.sender, _amountToMint);
        return true;
    }

    function withdraw(uint256 _tknValue) public returns (bool) {
        uint256 _supplyWei = nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance;
        uint256 _amountToSend = (_tknValue * _balanceWei) / _supplyWei;

        address payable _withdrawer = payable(msg.sender);
        nativeToken.burn(msg.sender, _tknValue);
        _withdrawer.transfer(_amountToSend);
        return true;
    }
}