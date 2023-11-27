// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
import "contracts/polygon/deps/uniswap/v3-periphery/libraries/OracleLibrary.sol";
import "contracts/polygon/deps/uniswap/interfaces/IUniswapV3Factory.sol";

interface IERC20Slice { function decimals() external view returns (uint8); }

/// pls uniswap update your compilers!
/// based on openzeppelin's 'vintage' safe math lib
/// ref: https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) { return 0; }
        uint c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        uint c = a - b;
        return c;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }
}

/// should not use this adaptor on different version other than 0.7.6
/// note that in this version overflow is possible so safe math is required
/// not compatible with any other components or contracts native to dreamcatcher
/// DO NOT ATTEMPT TO PLUG THIS INTO A DIAMOND or UPGRADEABLE contract, it WILL cause untested behaviour
library UniswapV3OracleAdaptorComponent {
    using SafeMath for uint;

    event UniswapV3OracleAdaptorFactorySet(address oldFactory, address newFactory);
    event UniswapV3OracleAdaptorSecondsAgoSet(uint32 oldSecondsAgo, uint32 newSecondsAgo);

    struct UniswapV3OracleAdaptor {
        IUniswapV3Factory _factory;
        uint32 _secondsAgo;
    }

    function computeAsEtherValue(uint value, uint8 decimals) internal pure returns (uint) {
        return value.mul(10**18).div(10**decimals).mul(10**18).div(10**18);
    }

    function factory(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor) internal view returns (address) {
        return address(uniswapV3OracleAdaptor._factory);
    }

    function secondsAgo(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor) internal view returns (uint32) {
        return uniswapV3OracleAdaptor._secondsAgo;
    }

    function quote(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor, address token0, address token1) internal view returns (uint) {
        IERC20Slice tkn0 = IERC20Slice(token0);
        IERC20Slice tkn1 = IERC20Slice(token1);
        uint sum;
        uint success;
        uint24[] memory fees = new uint24[](2);
        fees[0] = 100;
        fees[1] = 500;
        fees[2] = 1000;
        for (uint i = 0; i < fees.length; i++) {
            address pool = uniswapV3OracleAdaptor._factory.getPool(token0, token1, fees[i]);
            (int24 tick,) = OracleLibrary.consult(pool, secondsAgo(uniswapV3OracleAdaptor));
            uint amountOut = OracleLibrary.getQuoteAtTick(tick, uint128(10**tkn0.decimals()), token0, token1);
            if (amountOut != 0) {
                amountOut = computeAsEtherValue(amountOut, tkn1.decimals());
                sum.add(amountOut);
                success += 1;
            }
        }
        if (success == 0) { return 0; }
        uint quote_ = sum.div(success);
        /// returns as 10**18
        return quote_;
    }

    function setFactory(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor, address factory_) internal returns (bool) {
        address oldFactory = factory(uniswapV3OracleAdaptor);
        uniswapV3OracleAdaptor._factory = IUniswapV3Factory(factory_);
        emit UniswapV3OracleAdaptorFactorySet(oldFactory, factory_);
        return true;
    }

    function setSecondsAgo(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor, uint32 seconds_) internal returns (bool) {
        uint32 oldSecondsAgo = secondsAgo(uniswapV3OracleAdaptor);
        uniswapV3OracleAdaptor._secondsAgo = seconds_;
        emit UniswapV3OracleAdaptorSecondsAgoSet(oldSecondsAgo, seconds_);
        return true;
    }

    function _setFactory(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor, address factory_) private returns (bool) {
        uniswapV3OracleAdaptor._factory = IUniswapV3Factory(factory_);
        return true;
    }

    function _setSecondsAgo(UniswapV3OracleAdaptor storage uniswapV3OracleAdaptor, uint32 seconds_) private returns (bool) {
        uniswapV3OracleAdaptor._secondsAgo = seconds_;
        return true;
    }
}