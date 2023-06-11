# Authenticator Contract

This contract is a role-based access control mechanism built on top of OpenZeppelin Contracts. It allows for the management of roles and permissions within a smart contract system.

## License

This contract is licensed under the GPL-2.0-or-later license.

## Dependencies

This contract depends on the following OpenZeppelin Contracts:

- [AccessControlEnumerable.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControlEnumerable.sol)
- [IAccessControl.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/IAccessControl.sol)
- [Context.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol)
- [Strings.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol)
- [ERC165.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ERC165.sol)

Please make sure to include these dependencies when deploying or using the Authenticator contract.

## Usage

### Roles

Roles are used to represent a set of permissions within the contract. Each role is identified by a unique bytes32 identifier. The contract provides functions to grant, revoke, and check roles.

#### Role Identifiers

Roles should be defined as bytes32 constants in the external API. Here's an example of how to define a role:

```solidity
bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
