pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/Token.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/ClosedPool/State.sol";

contract Pool {
    State state;
    Token nativeToken;

    constructor (
        string memory _name,
        string memory _description,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenInitialSupply
    ) payable {
        address _creator =msg.sender;

        require(msg.value >=0.01 *10 **18);
        require(_tokenInitialSupply >=1);
        require(_creator !=address(0));
        
        nativeToken =new Token(_tokenName, _tokenSymbol);
        nativeToken.mint(_creator, _tokenInitialSupply);

        state =new State();
    }
    
    function contribute() onlyWhitelisted public payable returns (bool) {
        uint256 _valueWei =msg.value;
        uint256 _supplyWei =nativeToken.totalSupply() /10 **18;
        uint256 _balanceWei =address(this).balance -_valueWei;
        uint256 _amountToMint =(_valueWei *_supplyWei) /_balanceWei;

        address payable _to =payable(address(state));

        require(_valueWei >0);
        require(_supplyWei >0);
        require(_balanceWei >0);

        // transfer to state
        _to.transfer(_valueWei);

        // mint tokens and give them to the contributor
        nativeToken.mint(msg.sender, _amountToMint);

        emit Contribution(msg.sender, _valueWei *10 **18, _amountToMint);

        return true;
    }
    
    function withdraw(uint256 _tokenValue) public returns (bool) {
        uint256 _supplyWei =nativeToken.totalSupply() /10 **18;
        uint256 _balanceWei =address(this).balance;
        uint256 _amountToSend =(_tokenValue *_balanceWei) /_supplyWei;

        address payable _sender =payable(msg.sender);

        // burn the withdrawer's tokens
        nativeToken.burn(msg.sender, _tokenValue);

        // recieve matic from the state contract
        state._withdraw_(_amountToSend);

        // send matic to the sender
        _sender.transfer(_amountToSend);        

        emit Withdrawal(_sender, _tokenValue, _amountToSend);

        return true;
    }
}