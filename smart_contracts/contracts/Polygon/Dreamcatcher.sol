// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
) storage of accounting will have to be by address and contract first not taking the symbol for id
) new tier system implemented
 */

contract State {
    /** map */
    mapping(string=>address) internal map;
    /** accounting */
    mapping(address=>uint256) internal ask;
    mapping(address=>uint256) internal bid;
    mapping(address=>uint256) internal available;
    mapping(address=>bool)    internal swappable;
    /** authenticator 0, 1, 2, 3*/
    mapping(address=>uint256) internal tier;
}

contract Authenticator is State {

    modifier tier_1() {
        require(
            tier[msg.sender] >= 1
        );
        _;
    }

    modifier tier_2() {
        require(
            tier[msg.sender] >= 2
        );
        _;
    }

    modifier tier_3() {
        require(
            tier[msg.sender] >= 3
        );
        _;
    }
    
    function permission_upgrade(address _owner) public tier_3 returns (bool) {
        require(
            tier[_owner] < 3 &&
            tier[_owner] >= 0
        );
        tier[_owner] += 1;
        return true;
    }

    function permission_downgrade(address _owner) public tier_3 returns (bool) {
        require(
            tier[_owner] < 3 &&
            tier[_owner] >= 0
        );
        tier[_owner] -= 1;
        return true;
    }

    function update_map(string _name, address _location) public tier_3 returns (bool) {
        map[_name] = _location;
        return true;
    }

    function fetch_map(string _name) public tier_1 returns (address) {
        return map[_name];
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function decimals() external view returns (uint8);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 _value_in,
        uint256 _value_out_min,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) external returns (uint256[] memory _values);
}

interface ITreasury {

    function update_holdings(
        string _symbol,
        address _contract,
        uint256 _value,
        uint256 _ask,
        uint256 _bid,
        uint256 _available,
        bool _swappable
    ) external returns (bool);

    function fetch_holdings(string _symbol) external returns (
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        bool
    );

    function swap_token_for_matic(string _symbol) payable external returns (bool);
    function swap_matic_for_token(string _symbol, uint256 _amount_of_tokens_for_sale) payable external returns (bool);
}

contract Treasury is Authenticator {

    constructor(address _native_token) {
        map["NATIVE_TOKEN"] = _native_token;
    }

    function update_holdings_(
        address _contract,
        uint256 _ask,
        uint256 _bid,
        uint256 _required,
        bool _swappable
    ) internal returns (bool) {
        
    }

    function update_holdings(
        address _contract,
        uint256 _ask,
        uint256 _bid,
        uint256 _required,
        bool _swappable
    ) external tier_3 returns (bool) {

    }
    /** tier 2 */
    function update_holdings(
        string _symbol,
        address _contract,
        uint256 _value,
        uint256 _ask,
        uint256 _bid,
        uint256 _available,
        bool _swappable
    ) internal returns (bool) {
        holdings_contract[_symbol] = _contract;
        holdings[_symbol] = _value;
        ask[_symbol] = _ask;
        bid[_symbol] = _bid;
        available[_symbol] = _available;
        swappable[_symbol] = _swappable;
    }
    /** tier 1 */
    function fetch_holdings(string _symbol) public returns (
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        bool
    ) {
        return (
            holdings_contract[_symbol],
            holdings[_symbol],
            ask[_symbol],
            bid[_symbol],
            available[_symbol],
            swappable[_symbol]
        );
    }

    function swap_token_for_matic(string _symbol) payable external returns (bool) {
        (
            address _contract,
            uint256 _value,
            uint256 _ask,
            uint256 _bid,
            uint256 _amount_available_for_sale,
            bool _swappable
        ) = fetch_holdings(_symbol);
        address _seller = address(this);
        address _buyers = msg.sender;
        uint256 _amount_of_tokens_requested = msg.value / _ask;
        IERC20 _token = IERC20(_contract);
        require(
            _swappable &&
            _amount_of_tokens_requested > 0 &&
            _amount_of_tokens_requested <= _token.balanceOf(_seller) &&
            _amount_of_tokens_requested <= _amount_available_for_sale &&
            _contract != address(0) &&
            _contract != 0
        );
        /** recieve matic */
        update_holdings(
            "MATIC",
            holdings_contract["MATIC"],
            holdings["MATIC"] += msg.value,
            ask["MATIC"],
            bid["MATIC"],
            available["MATIC"],
            swappable["MATIC"]
        );
        /** send token */
        update_holdings(
            _symbol,
            _contract,
            _value -= _amount_of_tokens_requested,
            _ask,
            _bid,
            _amount_available_for_sale -= _amount_of_tokens_requested,
            _swappable
        );
        _token.transfer(_buyers, _amount_of_tokens_requested);
        /** return */
        return true;
    }

    function swap_matic_for_token(string _symbol, uint256 _amount_of_tokens_for_sale) payable external returns (bool) {
        /** matic for sale */
        (
            address _contract_matic,
            uint256 _value_matic,
            uint256 _ask_matic,
            uint256 _bid_matic,
            uint256 _available_matic,
            bool _swappable_matic
        ) = fetch_holdings("MATIC");
        /** purchasing tokens */
        (
            address _contract,
            uint256 _value,
            uint256 _ask,
            uint256 _bid,
            uint256 _available,
            bool _swappable
        ) = fetch_holdings(_symbol);
        address _seller = msg.sender;
        address _buyers = address(this);
        uint256 _amount_of_matic_to_release;
        IERC20 _token = IERC20(_contract);
        require(
            _swappable_matic &&
            _available < 0 &&
            _amount_of_matic_to_release > 0 &&
            _amount_of_matic_to_release <= _available_matic &&
            _amount_of_tokens_for_sale <= _token.balanceOf(_seller) &&
            _contract != address(0) &&
            _contract != 0
        );
        /** receieve tokens */
        update_holdings(
            _symbol,
            _contract,
            _value += _amount_of_tokens_for_sale,
            _ask,
            _bid,
            _available += _amount_available_for_sale,
            _swappable
        );
        _token.transferFrom(_seller, _buyers, _amount_available_for_sale);
        /** send matic */
        update_holdings(
            "MATIC",
            _contract_matic,
            _value_matic -= _amount_of_matic_to_release,
            _ask_matic,
            _bid_matic,
            _available_matic -= _amount_of_matic_to_release,
            _swappable_matic
        );
        _buyers.transfer(_amount_of_matic_to_release);
        /** return */
        return true;
    }
    /** in theory this should swap tokens in the vault in uniswap */
    function swap_on_uniswap(
        address _contract_in,
        address _contract_out,
        uint256 _value_in,
        uint256 _value_out_min
    ) external tier_2 returns (bool) {
        _to = address(this);
        IERC20 _token_in = IERC20(_contract_in);
        IERC20 _token_out = IERC20(_contract_out);

        IERC20(_contract_in).transferFrom(msg.sender, address(this), _value_in);
        IERC20(_contract_out).approve(map["UNISWAP_V2_ROUTER"], _value_in);

        (
            address _contract,
            uint256 _value,
            uint256 _ask,
            uint256 _bid,
            uint256 _available,
            bool _swappable
        ) = fetch_holdings("WETH");

        address[] memory _path;
        _path = new address[](3);
        _path[0] = _contract_in;
        _path[1] = _contract;
        _path[2] = _contract_out;

        IUniswapV2Router(map["UNISWAP_V2_ROUTER"]).swapExactTokensForTokens(
            _value_in,
            _value_out_min,
            _path,
            _to,
            block.timestamp
        );
    }
    /** note some tokens may have the same token symbol or name which will break this function and update and fecth method must correct */
    function deposit_ERC20(address _contract, uint256 _value) payable external returns (bool) {
        address _form = msg.sender;
        address _to = address(this);
        IERC20 _token = IERC20(_contract);
        _symbol = _token.symbol();
        (
            _contract_token,
            _value_token,
            _ask,
            _bid,
            _available,
            _swappable
        ) = fetch_holdings(_symbol);
        require(
            _value <= _token.balanceOf(_from) &&
            _value >= 0 &&
            _from != address(0)
        );
        bool _success = _token.transferFrom(_from, _to, _value * 10**_token.decimals);
        update_holdings(
            _token.symbol(),
            _contract_token,
            holdings[_token.symbol()] += _value,
            _ask,
            _bid,
            _available,
            _swappable
        );
        return true;
    }

    function withdraw_ERC20(address _contract) payable external tier_2 returns (bool) {

    }

    function stake(address _contract) payable external returns (bool) {

    }

    function unstake(address _contract) 

}