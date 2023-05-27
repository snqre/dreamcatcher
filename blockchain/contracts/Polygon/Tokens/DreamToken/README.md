# DreamToken

DreamToken is an ERC-20 standard token built on the Ethereum blockchain. It provides a decentralized digital currency solution with additional features such as burning tokens, snapshotting, and voting capabilities. The token aims to symbolize the power of imagination and the importance of pursuing one's passions.

## Contract Overview

The `DreamToken` contract is implemented in Solidity and extends various OpenZeppelin contracts to inherit standard ERC-20 functionality and additional features. The contract includes the following imports from OpenZeppelin:

- `ERC20`: Implements the ERC-20 token standard.
- `ERC20Burnable`: Adds the ability to burn tokens.
- `ERC20Snapshot`: Allows for creating snapshots of token balances.
- `Ownable`: Provides basic access control functionality.
- `ERC20Permit`: Enables permit signatures for token approvals.
- `ERC20Votes`: Implements voting and governance functionalities.

## Token Details

- Name: DreamToken
- Symbol: DREAM
- Decimals: 18

## Contract Variables

- `mintable_`: The remaining amount of tokens that can be minted.
- `maxSupply_`: The maximum supply of tokens that can ever exist.
- `minBurnTransferFee`, `minBankTransferFee`, `maxBurnTransferFee`, `maxBankTransferFee`: Various fee parameters in basis points for token transfers.
- `burnTransferFee`: The burn fee for token transfers.
- `bankTransferFee`: The fee sent to the DAO on token transfers.
- `safe`: The address where the bank fee is sent on transfers.

## Contract Functions

### Public Functions

- `maxSupply()`: Retrieves the maximum supply of tokens.
- `mintable()`: Retrieves the remaining amount of tokens that can be minted.

### Owner Functions

- `snapshot()`: Creates a snapshot of token balances.
- `mint(address to, uint256 amount)`: Mints new tokens and assigns them to the specified address.
- `renounceOwnership()`: Allows the current owner to renounce their ownership.
- `transferOwnership(address newOwner)`: Transfers ownership of the contract to a new address.
- `setNewSafeAddress(address newSafeAddress)`: Sets a new address where the bank fee is sent on transfers.

## Development

DreamToken is built using the Solidity programming language and leverages the OpenZeppelin library for standard ERC-20 functionality and extensions. The code is available on the Ethereum mainnet.

## License

DreamToken is open-source software licensed under the [GPL-2.0-or-later](https://spdx.org/licenses/GPL-2.0-or-later.html) license.

## Disclaimer

DreamToken is provided as-is without any warranties or guarantees. Users should exercise caution and do their own due diligence when interacting with the token contract or any associated platforms.
