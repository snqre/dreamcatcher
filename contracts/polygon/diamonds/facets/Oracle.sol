// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV2Router02.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMath.sol";
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/diamonds/facets/security/NonReentrant.sol";
import "contracts/polygon/diamonds/facets/security/Pausable.sol";

interface IOracle {
    function ____mapExchange(string memory exchange_, address newFactory, address oldRouter) external;

    function exchange(string memory exchange_) external view returns (address, address);
    function averageValue(string[] memory exchanges, address token0, address token1, uint amount) external view returns (uint);
    function realAverageValue(string[] memory exchanges, address token0, address token1, uint amount) external view returns (uint);
    function value(string memory exchange_, address token0, address token1, uint amount) external view returns (uint);
    function realValue(string memory exchange_, address token0, address token1, uint amount) external view returns (uint);
    function quote(string memory exchange_, address token0, address token1) external view returns (uint);
    function amountOut(string memory exchange_, address token0, address token1) external view returns (uint);
    function amountsOut(string memory exchange_, address[] memory path) external view returns (uint);
}

contract Oracle is Pausable, NonReentrant {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _ORACLE = keccak256("slot.oracle");

    event ExchangeMappingsChanged(string indexed exchange, address oldFactory, address newFactory, address oldRouter, address newRouter);

    struct OracleStorage {
        mapping(string => Exchange) exchange;
    }

    struct Exchange {
        IUniswapV2Factory factory;
        IUniswapV2Router02 router;
    }

    modifier onlySelfOrAdmin() {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        _;
    }

    modifier onlyNonZeroExchange(string memory exchange) {
        require(!_isZeroExchange(exchange), "_isZeroExchange");
        _;
    }

    function oracle() internal pure virtual returns (OracleStorage storage s) {
        bytes32 location = _ORACLE;
        assembly {
            s.slot := location
        }
    }

    function ____mapExchange(string memory exchange_, address newFactory, address newRouter) onlySelfOrAdmin() whenNotPaused() nonReentrant() external virtual {
        _mapExchange(exchange, newFactory, newRouter);
    }

    function exchange(string memory exchange_) public view virtual returns (address, address) {
        return (address(oracle().exchange[exchange_].factory), address(oracle().exchange[exchange_].router));
    }

    function averageValue(string[] memory exchanges, address token0, address token1, uint amount) public view virtual returns (uint) {
        uint average;
        uint success;
        for (uint i = 0; i < exchanges.length; i++) {
            uint value = value(exchanges[i], token0, token1, amount);
            if (value != 0) {
                average += value;
                success += 1;
            }
        }
        return average / success;
    }

    function realAverageValue(string[] memory exchanges, address token0, address token1, uint amount) public view virtual returns (uint) {
        uint average;
        uint success;
        for (uint i = 0; i < exchanges.length; i++) {
            uint realValue = realValue(exchanges[i], token0, token1, amount);
            if (value != 0) {
                average += realValue;
                success += 1;
            }
        }
        return average / success;
    }

    function value(string memory exchange_, address token0, address token1, uint amount) public view virtual returns (uint) {
        /// amount as 10**18 : divide by 10**18 to get human readable value
        return (amount * quote(exchange_, token0, token1)) / 10**18;
    }

    function realValue(string memory exchange_, address token0, address token1, uint amount) public view virtual returns (uint) {
        /// amount as 10**18 : divide by 10**18 to get human readable value
        return (amount * amountOut(exchange_, token0, token1)) / 10**18;
    }

    function quote(string memory exchange_, address token0, address token1) onlyNonZeroExchange(exchange_) public view virtual returns (uint) {
        IToken token0Interface = IToken(token0);
        IToken token1Interface = IToken(token1);
        uint8 decimals0 = token0Interface.decimals();
        uint8 decimals1 = token1Interface.decimals();
        address pair = oracle().exchange[exchange_].factory.getPair(token0, token1);
        if (pair == address(0)) {
            return 0;
        }
        IUniswapV2Pair pairInterface = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pairInterface.getReserves();
        if (token0 == pairInterface.token0()) {
            /// same layout
            uint amount = 10**decimals0;
            uint result = oracle().exchange[exchange].router.quote(amount, res0, res1);
            /// compute 10**decimals1 : return as 10**18
            result = OurMath.computeAsEtherValue(result, decimals1);
            return result;
        } else {
            /// **likely** reverse layout
            uint amount = 10**decimals1;
            uint result = oracle().exchange[exchange].router.quote(amount, res0, res1);
            /// compute 10**decimals1 : return as 10**18
            result = OurMath.computeAsEtherValue(result, decimals1);
            return result;
        }
    }

    function amountOut(string memory exchange_, address token0, address token1) onlyNonZeroExchange(exchange) public view virtual returns (uint) {
        IToken token0Interface = IToken(token0);
        IToken token1Interface = IToken(token1);
        uint8 decimals0 = token0Interface.decimals();
        uint8 decimals1 = token1Interface.decimals();
        address pair = oracle().exchange[exchange_].factory.getPair(token0, token1);
        if (pair == address(0)) {
            return 0;
        }
        IUniswapV2Pair pairInterface = IUniswapV2Pair(pair);
        (uint res0, uint res1,) = pairInterface.getReserves();
        if (token0 == pairInterface.token0()) {
            /// same layour
            uint amount = 10**decimals0;
            uint result = oracle().exchange[exchange_].router.getAmountOut(amount, res0, res1);
            /// compute 10**decimals1 : return as 10**18
            result = OurMath.computeAsEtherValue(result, decimals1);
            return result;
        } else {
            /// **likely** reverse layout
            uint amount = 10**decimals1;
            uint result = oracle().exchange[exchange_].router.getAmountOut(amount, res0, res1);
            /// compute 10**decimals1 : return as 10**18
            result = OurMath.computeAsEtherValue(result, decimals1);
            return result;
        }
    }

    function amountsOut(string memory exchange_, address[] memory path) onlyNonZeroExchange(exchange) public view virtual returns (uint) {
        IToken token0Interface = IToken(path[0]);
        IToken token1Interface = IToken(path[path.length - 1]);
        uint8 decimals0 = token0Interface.decimals();
        uint8 decimals1 = token1Interface.decimals();
        uint amount = 10**decimals0;
        uint[] memory results = oracle().exchange[exchange_].router.getAmountsOut(amount, path);
        uint result = results[results.length - 1];
        result = OurMath.computeAsEtherValue(result, decimals1);
        return result;
    }

    function _isSelfOrAdmin() internal view virtual {
        return msg.sender == IConsole(address(this)).admin() || msg.sender == address(this);
    }

    function _isZeroExchange(string memory exchange_) internal view virtual {
        (address factory, address router) = exchange(exchange_);
        return factory == address(0) || router == address(0);
    }

    function _mapExchange(string memory exchange_, address newFactory, address newRouter) internal virtual {
        (address oldFactory, address oldRouter) = exchange(exchange_);
        oracle().exchange[exchange_] = Exchange(newFactory, newRouter);
        emit ExchangeMappingsChanged(exchange_, oldFactory, newFactory, oldRouter, newRouter);
    }
}