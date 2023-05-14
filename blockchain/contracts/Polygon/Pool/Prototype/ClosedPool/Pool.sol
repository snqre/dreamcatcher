// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/Token.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/ClosedPool/State.sol";

contract Pool {
    State state;
    Token nativeToken;

    struct My {
        address state;
    } My private my;

    constructor (
        string memory _name,
        string memory _description,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenInitialSupply,
        uint256 _duration,
        uint256 _required,
        bool _whitelisted,
        bool _transferable,
        uint256 _secondsToHarvest,
        uint256 _durationHarvest
    ) payable {
        require(msg.value > 0.01 *10 **18);
        require(_tokenInitialSupply >= 1);

        address _logic =address(this);
        address _creator =msg.sender;
        address _governor =address(this);

        state =new State(
            _logic,
            _creator,
            _governor,
            _name,
            _duration,
            _required,
            _whitelisted,
            _transferable,
            _secondsToHarvest,
            _durationHarvest
        );

        my.state =address(state);
        // create native token contract for pool
        nativeToken =new Token(_tokenName, _tokenSymbol);
        // mint initial supply for the initial value paid by creator
        nativeToken.mint(_creator, _tokenInitialSupply);

        (
            bool _isOnWhitelist,
            bool _isManager,
            uint256 _contribution,
            uint256 _collateral
        ) =state.getOf(msg.sender);

        uint256 _newContribution =_contribution +=msg.value;
        state.setOf(
            msg.sender,
            true,
            true,
            _newContribution,
            _collateral
        );
    }

    function contribute() public payable returns (bool) {
        (
            uint256 _begin,
            uint256 _minDuration,
            uint256 _maxDuration,
            uint256 _duration,
            uint256 _end,
            uint256 _required,
            bool _whitelisted,
            bool _transferable,
            bool _successful
        ) =state.getFunding();

        uint256 _now =block.timestamp;
        uint256 _valueWei =msg.value;
        uint256 _supplyWei =nativeToken.totalSupply() /10 **18;
        uint256 _balanceWei =address(this).balance -_valueWei;
        uint256 _amountToMint =(_valueWei *_supplyWei) /_balanceWei;

        require(_now <=_end); 
        
        (
            bool _isOnWhitelist,
            bool _isManager,
            uint256 _contribution,
            uint256 _collateral
        ) =state.getOf(msg.sender);
            
        if (_whitelisted) {require(_isOnWhitelist);}

        address payable _to =payable(address(state));

        require(_valueWei >0);
        require(_supplyWei >0);
        require(_balanceWei >0);
        // send matic to state contract
        _to.transfer(_valueWei);
        // mint equivalent tokens to the contributor
        nativeToken.mint(msg.sender, _amountToMint);

        uint256 _newContribution =_contribution +=_valueWei;
        state.setOf(
            msg.sender,
            _isOnWhitelist,
            _isManager,
            _newContribution,
            _collateral
        );

        return true;
    }

    function withdraw(uint256 _value) public returns (bool) {
        (
            uint256 _begin,
            uint256 _minDuration,
            uint256 _maxDuration,
            uint256 _duration,
            uint256 _end,
            uint256 _required,
            bool _whitelisted,
            bool _transferable,
            bool _successful
        ) =state.getFunding();

        uint256 _now =block.timestamp;
        uint256 _supplyWei =nativeToken.totalSupply() /10 **18;
        uint256 _balanceWei =address(this).balance;
        uint256 _amountToSend =(_value *_balanceWei) /_supplyWei;

        if (_required ==0) {_now <=_end;}
        else {require(_successful ==false);}

        address payable _sender =payable(msg.sender);
        // burn value
        nativeToken.burn(msg.sender, _value);
        // pull matic from state contract
        state.withdraw(_amountToSend);

        (
            bool _isOnWhitelist,
            bool _isManager,
            uint256 _contribution,
            uint256 _collateral
        ) =state.getOf(msg.sender);

        uint256 _newContribution =_contribution -=_amountToSend;
        state.setOf(
            msg.sender,
            _isOnWhitelist,
            _isManager,
            _newContribution,
            _collateral
        );
        // send matic to withdrawer
        _sender.transfer(_amountToSend);

        return true;
    }
    
    function whitelist(address _domain, bool _isOnWhitelist) public returns (bool) {
        (
            bool _isOnWhitelist0x0,
            bool _isManager,
            uint256 _contribution,
            uint256 _collateral
        ) =state.getOf(msg.sender);

        require(_isManager);

        state.setOf(
            _domain,
            _isOnWhitelist,
            _isManager,
            _contribution,
            _collateral
        );

        return true;
    }

    function transfer(address _to, uint256 _valueWei) public returns (bool) {
        (
            uint256 _begin,
            uint256 _minDuration,
            uint256 _maxDuration,
            uint256 _duration,
            uint256 _end,
            uint256 _required,
            uint256 _whitelisted,
            uint256 _transferable,
            uint256 _successful
        ) =state.getFunding();

        require(_transferable);

        (
            bool _isOnWhitelist,
            bool _isManager,
            uint256 _contribution,
            uint256 _collateral
        ) =state.getOf(msg.sender);

        require(_isManager);
        require(_valueWei <=_collateral);

        address payable _recipient =payable(_to);
        _recipient.transfer(_valueWei);
        return true;
    }


    function swap() public returns (bool) {
        require(managerOf(msg.sender));
        // perform swap
    }
}