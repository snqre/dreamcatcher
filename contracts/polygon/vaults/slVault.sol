// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/Shell.sol';
import 'contracts/polygon/units/20/slToken.sol';
import 'contracts/polygon/abstracts/ERC4626.sol';

/**
* @dev The vault follows the ERC4626 standard.
 */
contract slVault is Shell, slToken, ERC4626 {
}