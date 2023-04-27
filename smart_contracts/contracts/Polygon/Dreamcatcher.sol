// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract State {
    /** accounting */
    mapping(string=>address) internal holdings_contract;
    mapping(string=>uint256) internal holdings;
    mapping(string=>uint256) internal ask;
    mapping(string=>uint256) internal bid;
    mapping(string=>uint256) internal available;
    mapping(string=>bool) internal swappable;
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

contract Treasury {

    function update_holdings(
        string _symbol,
        address _contract,
        uint256 _value,
        uint256 _ask,
        uint256 _bid,
        uint256 _available,
        bool _swappable
    ) private returns (bool) {
        holdings_contract[_symbol] = _contract;
        holdings[_symbol] = _value;
        ask[_symbol] = _ask;
        bid[_symbol] = _bid;
        available[_symbol] = _available;
        swappable[_symbol] = _swappable;
    }

    function fetch_holdings(string _symbol) private returns (
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
}