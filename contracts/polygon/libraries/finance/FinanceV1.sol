// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/libraries/shared/Shared.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Factory.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Pair.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

library FinanceV1 {
    function amountToMint(uint256 v, uint256 s, uint256 b) public pure returns (uint256) {
        if (
            v == 0 ||
            s == 0 ||
            b == 0
        ) {
            revert ValueIsZero();
        }
        return ((v * s) / b);
    }

    function amountToSend(uint256 a, uint256 s, uint256 b) public pure returns (uint256) {
        if (
            a == 0 ||
            s == 0 ||
            b == 0
        ) {
            revert ValueIsZero();
        }
        return ((a * b) / s);
    }
}

