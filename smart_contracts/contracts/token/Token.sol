// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RESTARTED, I THINK I CAN DO IT BETTER
// WE CANT USE OPENZEPPELIN BECAUSE THEY DONT ALLOW US TO FLEXIBLY EDIT
// BUT WILL BE BORROWING SOME OF THEIR BASE LINE FRAMEWORKS

/// @notice Token Contract
/// @dev It does token stuff and hurts my brain
/// @author Marco

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Capped.sol";
contract Token is ERC20Votes {
    
}