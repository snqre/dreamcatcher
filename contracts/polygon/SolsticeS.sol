// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IERC20 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name()
    external view
    returns (
        string memory
    );

    function symbol()
    external view
    returns (
        string memory
    );

    function decimals()
    external view
    returns (
        uint8
    );

    function totalSupply()
    external view
    returns (
        uint256
    );

    function balanceOf(
        address account
    )
    external view
    returns (
        uint256
    );

    function transfer(
        address to,
        uint256 amount
    )
    external
    returns (
        bool
    );

    function allowance(
        address owner,
        address spender
    )
    external view
    returns (
        uint256
    );

    function approve(
        address spender,
        uint256 amount
    )
    external
    returns (
        bool
    );

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
    external
    returns (
        bool
    );
}

interface IQuickSwapPlugIn {
    enum ORDER { REVERSE, SAME }

    function isSameString(
        string memory stringA,
        string memory stringB
    )
    external pure
    returns (
        bool isMatch
    );
    
    function metadata(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        address addressPair,
        address addressA,
        address addressB,
        string memory nameA,
        string memory nameB,
        string memory symbolA,
        string memory symbolB,
        uint decimalsA,
        uint decimalsB
    );
    
    function isSameOrder(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        ORDER
    );

    function price(
        address tokenA,
        address tokenB,
        uint amount
    )
    external view
    returns (
        uint price,
        uint lastTimestamp
    );

    function init()
    external;

    function whitelist(
        address account
    )
    external;

    function blacklist(
        address account
    )
    external;

    function grantRoleAdmin(
        address account
    )
    external;

    function revokeRoleAdmin(
        address account
    )
    external;

    function pause()
    external;

    function unpause()
    external;

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        uint gate,
        address from,
        address to
    )
    external;

    function swapTokensSlippage(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        uint gate,
        address from,
        address to
    )
    external;
}

/**
* _bytes    "solstice", <uint>, "asset"
*
*
*
* */
interface IRepository {

}

contract SolsticeHost {
    struct Holding {
        IERC20 interface_;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 price;
        uint256 lastTimestamp;
        uint256 amount;
    }

    struct Solstice {
        uint index;
        string name;
        string description;
        bool depositEnabled;
        bool withdrawEnabled;
        uint16 depositMin;
        uint16 depositMax;
        uint16 withdrawMin;
        uint16 withdrawMax;
        uint launch;
        IERC20 denominator;
        uint streamingFee;
        uint entryFee;
        uint exitFee;
        EnumerableSet.AddressSet admins;
        EnumerableSet.AddressSet managers;
        EnumerableSet.AddressSet authorizedIn;
        EnumerableSet.AddressSet authorizedOut;
        EnumerableSet.AddressSet recipientsStreamingFees;
        EnumerableSet.AddressSet recipientsEntryFees;
        EnumerableSet.AddressSet recipientsExitFees;
    }

    IQuickSwapPlugIn constant ORACLE = IQuickSwapPlugIn();

    error UNAUTHORIZED_TOKEN_IN();
    error UNAUTHORIZED_TOKEN_OUT();
    error PAIR_NOT_FOUND();
    error INSUFFICIENT_MATH();

    constructor() {}

    function createNewVault()
    public {
        
    }

    /// setter functions

    /// be able to calculate finances

    /// swap

    /// save trading data on chain?

    /// 


}