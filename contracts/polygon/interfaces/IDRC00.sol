// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/// most basic requirments for compliance
interface IDRC00
{
    function name()
    external view
    returns (string memory);

    function module()
    external view
    returns (string memory);

    function version()
    external view
    returns (uint256);
}