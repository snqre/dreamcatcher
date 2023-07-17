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
