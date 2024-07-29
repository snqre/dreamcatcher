// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { UD60x18, ud } from "../../imports/prb-math/UD60x18.sol";

function UD(uint256 x) pure returns (UD60x18) {
    return ud(x);
}

library Math {
    function amountToMint(UD60x18 assetsIn, UD60x18 assets, UD60x18 supply) internal pure returns (UD60x18) {
        return assetsIn.mul(supply).div(assets);
    }

    function amountToSend(UD60x18 supplyIn, UD60x18 assets, UD60x18 supply) internal pure returns (UD60x18) {
        return supplyIn.mul(assets).div(supply);
    }
    
    function slc(UD60x18 x, UD60x18 percentage) internal pure returns (UD60x18) {
        return x.div(UD(100e18)).mul(percentage);
    }

    function lss(UD60x18 x, UD60x18 y) internal pure returns (UD60x18 percentage) {
        return UD(100e18).sub(yld(x, y));
    }

    function yld(UD60x18 x, UD60x18 y) internal pure returns (UD60x18 percentage) {
        return x.eq(UD(0)) ? UD(0) : x >= y ? UD(100e18) : pct(x, y);
    }

    function pct(UD60x18 x, UD60x18 y) internal pure returns (UD60x18 percentage) {
        return x.div(y).mul(UD(100e18));
    }

    function cst(uint256 x, uint8 decimals0, uint8 decimals1) internal pure returns (uint256) {
        return x == 0 || decimals0 == decimals1 ? x : _muldiv(x, 10**decimals1, 10**decimals0);
    }

    function _muldiv(uint256 x, uint256 y, uint256 z) private pure returns (uint256) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / z;
            }
            require(z > prod1, "overf");
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, z)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = z & (~z + 1);
            assembly {
                z := div(z, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * z) ^ 2;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            inverse *= 2 - z * inverse;
            return prod0 * inverse;
        }
    }
}