// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMath.sol";

contract UniswapV2Adaptor {
    IUniswapV2Factory private immutable _FACTORY;
    IUniswapV2Router02 private immutable _ROUTER;
    string private _name;

    constructor(string name, address factory, address router) {
        _FACTORY = IUniswapV2Factory(factory);
        _ROUTER = IUniswapV2Router02(router);
        _name = name;
    }

    function FACTORY() public view virtual returns (address) {
        return address(_FACTORY);
    }

    function ROUTER() public view virtual returns (address) {
        return address(_ROUTER);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    /// return price of token as 10**18 value
    /// i sacrified a goat to get this working GOT SOLIDITY WHY NO DECIMALS
    function price(address token0, address token1) public view virtual returns (uint) {
        IToken token0Interface = IToken(token0);
        IToken token1Interface = IToken(token1);
        uint8 decimals0 = token0Interface.decimals();
        uint8 decimals1 = token1Interface.decimals();
        address pair = _FACTORY.getPair(token0, token1);
        require(pair != address(0), "UniswapV2Adaptor: invalid pair address");
        IUniswapV2Pair pairInterface = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pairInterface.getReserves();
        if (token0 == pairInterface.token0()) { /// same layout
            uint amount = 10**decimals0;
            result = _ROUTER.quote(amount, res0, res1);
            result = OurMath.computeAsEtherValue(result, decimals1); /// compute 10**6 as 10**18
            return result;
        } else { /// **likely** reverse layout
            uint amount = 10**decimals1;
            result = _ROUTER.quote(amount, res1, res0);
            result = OurMath.computeAsEtherValue(result, decimals1); /// compute 10**6 as 10**18
            return result;
        }
        revert("UniswapV2Adaptor: failed to retrive price");
    }

    
}