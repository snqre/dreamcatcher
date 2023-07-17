# Library Documentation: __Validator

The `__Validator` library provides granular authorization functionality through the manipulation and management of keys and data structures. It leverages the `EnumerableSet` library to handle efficient storage and retrieval of unique keys. The library also includes various utility functions to add, remove, and retrieve keys, as well as check for key matches.

## Data Structures

1. **Enum: Class**
   - This enumeration represents different classes of keys: `DEFAULT`, `TIMED`, `STANDARD`, and `CONSUMABLE`.

2. **Struct: Data**
   - This struct contains information related to a key. It includes the key's `Class`, `startTimestamp`, `endTimestamp`, and a `balance` value (of type `uint8`). The `startTimestamp` and `endTimestamp` provide an optional time range for the key's validity.

3. **Struct: Key**
   - This struct represents a key and holds its unique identifier (`id`) as a `bytes32`, along with the `Class`, `startTimestamp`, `endTimestamp`, and `balance` values.

## Functions

1. `encode(string memory value) public pure returns (bytes32)`
   - This function takes a string input `value` and returns the keccak256 hash of the input, represented as a `bytes32` value. This hash serves as a unique identifier for the key.

2. `isMatch(EnumerableSet.Bytes32Set storage keys, string memory key) public view returns (bool)`
   - This function checks if a given `key` exists in the `keys` set (a `Bytes32Set` from the `EnumerableSet` library) by hashing the key using `encode` and looking for a match in the set. It returns `true` if the key is found, and `false` otherwise.

3. `onlyIfMatch(EnumerableSet.Bytes32Set storage keys, string memory key) public view`
   - This function is a modifier-like function that uses `isMatch` to require that the given `key` exists in the `keys` set. If the key is not found, it reverts with the error message "__Validator: key match not found."

4. `onlyIfNotMatch(EnumerableSet.Bytes32Set storage keys, string memory key) public view`
   - Similar to `onlyIfMatch`, this function also acts as a modifier, ensuring that the given `key` does not exist in the `keys` set. If the key is found, it reverts with the error message "__Validator: key match was found."

5. `add(EnumerableSet.Bytes32Set storage keys, string memory key) public`
   - This function adds a new `key` to the `keys` set by hashing it with `encode` and adding it to the set.

6. `remove(EnumerableSet.Bytes32Set storage keys, string memory key) public`
   - This function removes a given `key` from the `keys` set by hashing it with `encode` and removing it from the set.

7. `addKey(EnumerableSet.Bytes32Set storage keys, Data storage data, string memory key, Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance) public`
   - This function creates a new key entry by adding the `key` to the `keys` set and populating the associated `data` struct with the provided `class`, `startTimestamp`, `endTimestamp`, and `balance`.

8. `removeKey(EnumerableSet.Bytes32Set storage keys, Data storage data, string memory key) public`
   - This function removes a key from the `keys` set and resets the associated `data` struct to its default values.

9. `getKey(EnumerableSet.Bytes32Set storage keys, Data storage data, string memory key) public view returns (Key memory)`
   - This function retrieves information about a specific `key`. It verifies that the key exists in the `keys` set, and if found, returns a `Key` struct populated with its associated information from the `data` struct.

10. `getKeys(EnumerableSet.Bytes32Set storage keys, Data[] storage datas) public view returns (Key[] memory)`
    - This function returns an array of `Key` structs corresponding to all the keys in the `keys` set. It fetches the associated information from the `data` structs and compiles them into the array.

# Validator Contract Documentation

## Introduction
The `Validator` contract provides granular authorization functionality through the manipulation and management of keys. It allows users to grant and revoke access to specific addresses along with associated signatures, classes, start timestamps, end timestamps, and balance values. The contract implements the `IValidator` interface, which defines the external functions for managing keys.

## Interface: IValidator

The `IValidator` interface declares the external functions to manage keys, along with relevant events.

### Events

- **KeyRevoked**: Emitted when a key is revoked. It indicates the address from which the key is revoked (`from`), the address being revoked (`of_`), and the associated signature (`signature`).

- **KeyGranted**: Emitted when a key is granted. It indicates the address to which the key is granted (`to`), the address being granted (`of_`), the associated signature (`signature`), the class of the key (`class`), the start timestamp (`startTimestamp`), the end timestamp (`endTimestamp`), and the balance value (`balance`).

- **Authorized**: Emitted when a key is successfully validated. It indicates the address from which the validation is done (`from`), the address being validated (`of_`), and the associated signature (`signature`).

## Functions

- `revoke(address from, address of_, string memory signature) external`
  - This function revokes the access key associated with the specified signature. It can only be called by the key owner (`from`). Emits `KeyRevoked` event upon successful revocation.

- `grant(address to, address of_, string memory signature, __Validator.Class class, uint32 startTimestamp, uint32 endTimestamp, uint8 balance) external`
  - This function grants access to the specified address with the provided signature, class, start timestamp, end timestamp, and balance. It can only be called by the key owner (`to`). Emits `KeyGranted` event upon successful granting.

- `validate(address from, address of_, string memory signature) external`
  - This function validates the access key of the specified address (`of_`) and signature. It ensures the key is valid and performs necessary checks based on the key's class and timestamps. Emits `Authorized` event upon successful validation.

- `getKey(address from, address of_, string memory signature) external view returns (bytes32, __Validator.Class, uint32, uint32, uint8)`
  - This function retrieves the key information associated with the specified address and signature. It returns the key's ID, class, start timestamp, end timestamp, and balance.

- `getKeys(address from) external view returns (bytes32[] memory, __Validator.Class[] memory, uint32[] memory, uint32[] memory, uint8[] memory)`
  - This function retrieves all keys associated with the specified address. It returns arrays of key IDs, classes, start timestamps, end timestamps, and balances.
