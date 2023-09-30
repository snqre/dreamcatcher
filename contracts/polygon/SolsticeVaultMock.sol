// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/libraries/__Finance.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IERC20Mintable.sol";

import "contracts/polygon/ERC20Mintable.sol";

/**
* => Depsit => Management => Withdrawal
* 
*
 */
contract SolsticeVault {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct UniswapV2 {
        address router;
        address factory;
        string name;
    }

    uint256 public minDeposit;

    uint256 public maxDeposit;

    uint256 public minWithdrawal;

    uint256 public maxWithdrawal;
    
    address public denominator;

    bool public live;

    address private _token;

    UniswapV2[] private _uniswapV2s;

    EnumerableSet.AddressSet private _allowedIn;

    EnumerableSet.AddressSet private _allowedOut;

    constructor() {

        _uniswapV2s.push(
            UniswapV2({
                router: 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff,
                factory: 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32,
                name: "quickswap"
            })
        );

        _uniswapV2s.push(
            UniswapV2({
                router: 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506,
                factory: 0xc35DADB65012eC5796536bD9864eD8773aBc74C4,
                name: "sushiswap"
            })
        );

        _uniswapV2s.push(
            UniswapV2({
                router: 0x10f4A785F458Bc144e3706575924889954946639,
                factory: 0x9F3044f7F9FC8bC9eD615d54845b4577B833282d,
                name: "meshswap"
            })
        );

        /** USDT */
        denominator = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

        
    }

    function token() public view returns (address) {

        return _token;
    }

    function totalSupply() public view returns (uint256) {

        return IERC20Metadata(token()).totalSupply();
    }

    function factories() public view returns (address[] memory) {

        address[] memory factories;

        factories = new address[](_uniswapV2s.length);

        for (uint256 i = 0; i < _uniswapV2s.length; i++) {

            factories[i] = _uniswapV2s[i].factoy;
        }

        return factories;
    }

    /**
    * @dev 
     */
    function price(address tokenA, uint256 amount) public view returns (uint256) {

        return __Finance.meanPrice(factories(), tokenA, denominator, amount);
    }

    function balance() public view returns (uint256) {

        return __Finance.netAssetValue({factories: factories(), tokens: _allowedIn.values(), denominator: denominator});
    }

    function deposit(address tokenIn, uint256 amountIn) public {

        _onlyAllowedIn({tokenIn: tokenIn});

        uint256 value = price({tokenA: tokenIn, amount: amountIn});

        uint256 amountToMint = __Finance.amountToMint({v: value, s: totalSupply(), b: balance()});

        IERC20Mintable(token()).mint(msg.sender, amountToMint);
    }
    
    function _onlyAllowedIn(address tokenIn) internal view {

        require(_allowedIn.contains(tokenIn), "SolsticeVault: !allowedIn");
    }

    

}