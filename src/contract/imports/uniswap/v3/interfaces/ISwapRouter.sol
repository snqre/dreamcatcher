// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;
import { ExactInputSingleParams } from "../structs/ExactInputSingleParams.sol";
import { ExactInputParams } from "../structs/ExactInputParams.sol";
import { ExactOutputSingleParams } from "../structs/ExactOutputSingleParams.sol";
import { ExactOutputParams } from "../structs/ExactOutputParams.sol";

interface ISwapRouter {
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}