// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "dreamcatcher/.deps/openzeppelin/contracts/token/ERC20/ERC20.sol";
import "dreamcatcher/.deps/openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "dreamcatcher/.deps/openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "dreamcatcher/.deps/openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "dreamcatcher/.deps/openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract NativeToken is
    ERC20,
    ERC20Votes,
    ERC20Snapshot,
    ERC20Permit,
    ERC20Capped
{
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 cap
    ) ERC20("Dreamcatcher", "DREAM") ERC20Capped(200000000 * 10**decimals()) {}
}
