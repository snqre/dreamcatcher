// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Pool/Prototype/pool/state.sol";
import "blockchain/contracts/Polygon/Pool/Prototype/pool/token.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

interface ILogic {
    function contribute() external payable returns (bool);
    function withdraw(uint256 _tokens_to_burn) external returns (bool);
}

contract Logic is ILogic, Safety {
    State state;
    Token native_token;

    constructor(
        string memory _name,
        uint256 _duration,
        uint256 _required,
        bool _whitelisted,
        string memory _token_name,
        string memory _token_symbol,
        uint256 _token_initial_supply

    ) payable {
        require(msg.value >0.01 *10 **18);
        require(_token_initial_supply >=1);

        address _logic       =address(this);
        address _creator     =msg.sender;
        address _governor    =msg.sender;

        state =new State(
            _logic,
            _creator,
            _governor,
            _name,
            _duration,
            _required,
            _whitelisted
        );

        native_token =new Token(
            _token_name,
            _token_symbol
        );

        native_token.mint(
            _creator,
            _token_initial_supply
        );

        (
            bool     _is_manager,
            bool     _is_on_whitelist,
            uint256  _flux
        ) =state.pull_profile(_creator);

        uint256 _new_flux_value =_flux +msg.value;
        state.push_profile(
            _creator, 
            true, 
            true, 
            _new_flux_value
        );
    }

    function contribute() public payable one_at_a_time returns (bool) {
        (
            uint256  _start,
            uint256  _end,
            uint256  _required,
            bool     _whitelisted,
            bool     _success
        ) =state.pull_launch();

        uint256 _now             =block.timestamp;
        uint256 _value_in_wei    =msg.value;
        uint256 _supply_in_wei   =native_token.totalSupply() /10 **18;
        uint256 _balance_in_wei  =address(this).balance -_value_in_wei;
        uint256 _amount_to_mint  =(_value_in_wei *_supply_in_wei) /_balance_in_wei;

        require(_value_in_wei >0, "logic: invalid math");
        require(_supply_in_wei >0, "logic: invalid math");
        require(_balance_in_wei >0, "logic: invalid math");

        require(_now <=_end, "logic: launch funding period has expired");

        (
           bool  _is_manager,
           bool  _is_on_whitelist,
           uint256   _flux 
        ) =state.pull_profile(msg.sender);  

        if (_whitelisted) {require(_is_on_whitelist);}

        address payable _to =payable(address(state));
        _to.transfer(_value_in_wei);
        
        native_token.mint(
            msg.sender,
            _amount_to_mint
        );

        uint256 _new_flux_value =_flux +_value_in_wei;
        state.push_profile(
            msg.sender, 
            _is_manager, 
            _is_on_whitelist, 
            _new_flux_value
        );

        return true;
    }

    function withdraw(uint256 _tokens_to_burn) public one_at_a_time returns (bool) {
        (
            uint256  _start,
            uint256  _end,
            uint256  _required,
            bool     _whitelisted,
            bool     _success
        ) =state.pull_launch();

        uint256 _now             =block.timestamp;
        uint256 _supply_in_wei   =native_token.totalSupply() /10 **18;
        uint256 _balance_in_wei  =address(this).balance;
        uint256 _amount_to_send  =(_tokens_to_burn *_balance_in_wei) /_supply_in_wei;
        
        if (_required ==0) {require(_now <=_end);}
        else {require(_success ==false);}

        address payable _burner =payable(msg.sender);
        native_token.burn(
            msg.sender,
            _tokens_to_burn
        );

        state.withdraw(_amount_to_send);

        (
            bool _is_manager,
            bool _is_on_whitelist,
            uint256 _flux
        ) =state.pull_profile(msg.sender);

        uint256 _new_flux_value =_flux -_amount_to_send;
        state.push_profile(
            msg.sender, 
            _is_manager, 
            _is_on_whitelist, 
            _new_flux_value
        );

        return true;
    }
}