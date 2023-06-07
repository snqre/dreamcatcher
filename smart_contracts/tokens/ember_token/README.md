# EmberToken

EmberToken is a Solidity contract that implements a token contract based on the ERC20 standard. It inherits functionality from various OpenZeppelin contracts to provide additional features such as burning, snapshotting, and permit functionality. The contract also implements an access control mechanism using the AccessControl contract.

## Prerequisites

- Solidity version: ^0.8.9
- OpenZeppelin contracts:
  - ERC20.sol
  - ERC20Burnable.sol
  - ERC20Snapshot.sol
  - AccessControl.sol
  - draft-ERC20Permit.sol

## Getting Started

To use EmberToken in your Solidity project, follow these steps:

1. Import the required OpenZeppelin contracts:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

Contract Details
Constructor
The constructor of EmberToken takes an address parameter terminal. If the message sender is the terminal address, it grants the DEFAULT_ADMIN_ROLE to the message sender. Otherwise, it grants the DEFAULT_ADMIN_ROLE to both the message sender and the terminal address.

Functionality
EmberToken provides the following additional functionality:

_split(uint mul): Splits the balances of all registered accounts by the specified multiplier.
_stack(uint div): Stacks the balances of all registered accounts by the specified divisor.
_mintByPoints(address to, uint points): Mints tokens to the specified address based on the provided points. Points should be between 1 and 10000.
snapshot(): Creates a snapshot of the current token balances.
mint(address to, uint amount): Mints tokens to the specified address.
getCurrentTotalSupply(): Returns the current total token supply.
getWeight(address account): Returns the weight of the specified account based on its balance in relation to the current total supply.
getPastWeight(address account, uint snapshotId): Returns the weight of the specified account at a specific snapshot based on its balance in relation to the total supply at that snapshot.