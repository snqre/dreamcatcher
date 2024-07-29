// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;

struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 amountInMaximum;
}