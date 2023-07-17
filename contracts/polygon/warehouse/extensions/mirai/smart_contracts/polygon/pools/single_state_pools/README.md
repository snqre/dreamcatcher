# SingleState Contract

SingleState is a smart contract that manages decentralized and centralized pools on the Polygon network. It allows users to create and contribute to pools, manage pool administration, and perform various operations related to pool funding and asset management.

## Prerequisites

Before using the SingleState contract, make sure you have the following prerequisites:

- Solidity compiler version 0.8.0 or higher
- Access to the Polygon network
- Required dependencies:
  - OpenZeppelin Contracts (ERC20, Ownable, ReentrancyGuard, etc.)
  - Utils.sol
  - SimpleToken.sol
  - Medium.sol

## Getting Started

To get started with the SingleState contract, follow these steps:

1. Import the necessary contracts and libraries:
   - OpenZeppelin contracts for ERC20, Ownable, ReentrancyGuard, and other functionality
   - Utils.sol for utility functions
   - SimpleToken.sol for the StandardToken contract
   - Medium.sol for the GovernanceToken contract

2. Define the StandardToken contract:
   - This contract represents a token used in centralized pools.
   - It extends ERC20, ERC20Burnable, ERC20Permit, and AccessControl contracts.
   - It provides functions for minting and burning tokens.

3. Define the GovernanceToken contract:
   - This contract represents a token used in decentralized and hybrid pools.
   - It extends ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, and AccessControl contracts.
   - It provides functions for minting, snapshotting, and obtaining voting power.

4. Define the ISingleState interface:
   - This interface includes an event for notifying the creation of a new pool.

5. Define the SingleState contract:
   - This contract manages the creation and management of pools.
   - It includes various data structures and mappings to store pool and account information.
   - It provides functions for creating pools, contributing to pools, and performing other pool-related operations.
   - It includes modifiers to restrict access to certain functions based on roles and permissions.

6. Initialize the SingleState contract:
   - Set up the contract by initializing necessary parameters and roles.
   - Set the terminal address, which represents the contract endpoint.
   - Set the lock-up period for contributors to withdraw their funds.

7. Start using the SingleState contract:
   - Call the appropriate functions to create pools, contribute to pools, and perform other operations.
   - Interact with the contract using different roles such as admins, creators, managers, and participants.
   - Follow the provided function comments for detailed usage instructions and requirements.

## License

This code is licensed under the GNU General Public License v2.0 or later. See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

The SingleState contract makes use of the following libraries and contracts:

- OpenZeppelin Contracts: [https://github.com/OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- Utils.sol: A utility library for common functions in the SingleState contract.
- SimpleToken.sol: A token contract used in centralized pools.
- Medium.sol: A token contract used in decentralized and hybrid pools.