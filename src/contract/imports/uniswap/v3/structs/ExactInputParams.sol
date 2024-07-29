// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;

struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
}