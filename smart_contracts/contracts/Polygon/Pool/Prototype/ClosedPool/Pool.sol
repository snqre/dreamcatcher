pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/Pool/Prototype/ClosedPool/State.sol";
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

/**
* seams like the main errors encountered on testnet are permissions
 */
contract Pool {
    
    State state;
    Token nativeToken;

    constructor(
        string memory _tknName,
        string memory _tknSymbol,
        uint256 _tknInitialSupply,
    ) {
        require(msg.value >= 1 * 10**18, "Pool: msg.value < 1 * 10**18");
        require(_tknInitialSupply >= 1 * 10**18, "Pool: _tknInitialSupply < 1 * 10**18");
        address _creator = msg.sender;
        nativeToken = new Token(_tknName, _tknSymbol);
        nativeToken.mint(_creator, _tknInitialSupply);
    }

    function contribute() public payable returns (bool) {
        uint256 _valueWei = msg.value;
        uint256 _supplyWei = nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance;
        uint256 _amountToMint = (_amount * _supply) / _balance;

        require(
            _valueWei > 0 * 10**18 &&
            _supplyWei > 0 * 10**18 &&
            _balanceWei > 0 * 10**18
        );

        nativeToken.mint(msg.sender, _amountToMint * 10**18);
        return true;
    }
}