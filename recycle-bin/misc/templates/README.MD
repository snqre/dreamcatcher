# Storage.sol

In the extended version, the "Storage" contract has been enhanced with additional functionality and improvements. Here are the updates:

Upgraded Solidity Version: The contract now uses Solidity version 0.8.19, which is a newer version with added features and optimizations.

Added Events: Events have been included throughout the contract to provide a convenient way for external applications to listen for updates and changes to the stored data. These events include "SetLogic," "SetString," "SetBytes," "SetUint," "SetInt," "SetAddress," "SetBool," "SetBytes32," and various array-related events.

Modified Function Modifiers: The "onlyOwner" modifier is applied to certain functions to ensure that only the contract owner can execute them. The contract inherits from the "Ownable" contract from the OpenZeppelin library to manage ownership.

Refactored Data Storage: The contract now uses private mappings to store the data, making them more secure and accessible only within the contract. Data for each type is stored in separate mappings, such as _string, _bytes, _uint, _int, _address, _bool, and _bytes32.

Improved Array Operations: The contract now has more efficient array handling mechanisms. Functions like "pushStringArray," "pushBytesArray," "pushUintArray," etc., are added to allow direct pushing of elements into the arrays, instead of using separate set functions.

Added Address, Uint, and Bytes32 Sets: EnumerableSet is utilized for managing sets of addresses, uints, and bytes32 values. This ensures efficient operations on these sets, such as adding, removing, checking existence, and fetching elements.

Separate "setLogic" Function: A new function "setLogic" is introduced to set the contract's logic address, which allows for upgrading the contract's functionality while keeping the stored data intact.

Interface Improvements: The "IStorage" interface has been updated to match the new functions and types added to the "Storage" contract.

These enhancements improve the security, efficiency, and functionality of the "Storage" contract, making it a more robust and versatile data storage solution for smart contract applications.

*** please not that the contract can have multiple logic contracts that use it, as well as, multiple admins that can manage it but cannot store data directly





