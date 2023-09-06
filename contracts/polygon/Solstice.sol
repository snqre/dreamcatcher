// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IRepository {
    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);
    function getBytes(bytes32 key) external view returns (bytes memory);
    function getUint(bytes32 key) external view returns (uint);
    function getInt(bytes32 key) external view returns (int);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key) external view returns (string[] memory);
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint index) external view returns (string memory);
    function getIndexedBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function getIndexedUintArray(bytes32 key, uint index) external view returns (uint);
    function getIndexedIntArray(bytes32 key, uint index) external view returns (int);
    function getIndexedAddressArray(bytes32 key, uint index) external view returns (address);
    function getIndexedBoolArray(bytes32 key, uint index) external view returns (bool);
    function getIndexedBytes32Array(bytes32 key, uint index) external view returns (bytes32);
    
    function getLengthStringArray(bytes32 key) external view returns (uint);
    function getLengthBytesArray(bytes32 key) external view returns (uint);
    function getLengthUintArray(bytes32 key) external view returns (uint);
    function getLengthIntArray(bytes32 key) external view returns (uint);
    function getLengthAddressArray(bytes32 key) external view returns (uint);
    function getLengthBoolArray(bytes32 key) external view returns (uint);
    function getLengthBytes32Array(bytes32 key) external view returns (uint);

    function getAddressSet(bytes32 key) external view returns (address[] memory);
    function getUintSet(bytes32 key) external view returns (uint[] memory);
    function getBytes32Set(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint index) external view returns (address);
    function getIndexedUintSet(bytes32 key, uint index) external view returns (uint);
    function getIndexedBytes32Set(bytes32 key, uint index) external view returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint);
    function getLengthUintSet(bytes32 key) external view returns (uint);
    function getLengthBytes32Set(bytes32 key) external view returns (uint);
    
    function addressSetContains(bytes32 key, address value) external view returns (bool);
    function uintSetContains(bytes32 key, uint value) external view returns (bool);
    function bytes32SetContains(bytes32 key, bytes32 value) external view returns (bool);

    function addAdmin(address account) external;
    function addLogic(address account) external;
    
    function removeAdmin(address account) external;
    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;
    function setBytes(bytes32 key, bytes memory value) external;
    function setUint(bytes32 key, uint value) external;
    function setInt(bytes32 key, int value) external;
    function setAddress(bytes32 key, address value) external;
    function setBool(bytes32 key, bool value) external;
    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(bytes32 key, uint index, string memory value) external;
    function setBytesArray(bytes32 key, uint index, bytes memory value) external;
    function setUintArray(bytes32 key, uint index, uint value) external;
    function setIntArray(bytes32 key, uint index, int value) external;
    function setAddressArray(bytes32 key, uint index, address value) external;
    function setBoolArray(bytes32 key, uint index, bool value) external;
    function setBytes32Array(bytes32 key, uint index, bytes32 value) external;

    function pushStringArray(bytes32 key, string memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function pushIntArray(bytes32 key, int value) external;
    function pushAddressArray(bytes32 key, address value) external;
    function pushBoolArray(bytes32 key, bool value) external;
    function pushBytes32Array(bytes32 key, bytes32 value) external;

    function deleteStringArray(bytes32 key) external;
    function deleteBytesArray(bytes32 key) external;
    function deleteUintArray(bytes32 key) external;
    function deleteIntArray(bytes32 key) external;
    function deleteAddressArray(bytes32 key) external;
    function deleteBoolArray(bytes32 key) external;
    function deleteBytes32Array(bytes32 key) external;
    
    function addAddressSet(bytes32 key, address value) external;
    function addUintSet(bytes32 key, uint value) external;
    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
}

library Safeguard {
    struct Keys {
        bytes32 admins;
        bytes32 managers;
        bytes32 name;
        bytes32 description;
        bytes32 balance;
        bytes32 ownedContracts;
        bytes32 depositEnabled;
        bytes32 depositMin;
        bytes32 depositMax;
        bytes32 lockUpPeriod;
        bytes32 entryFee;
        bytes32 exitFee;
        bytes32 streamingFee;
        bytes32 allowedAccounts;
        bytes32 nameToken;
        bytes32 symbolToken;
        bytes32 decimalsToken;
        bytes32 supplyToken;
    }

    function isRole(IRepository repository, address account)
    public view
    returns (
        bool isAdmin,
        bool isManager
    ) {
        Keys memory keys = _generateKeys();
        return (
            repository.addressSetContains(keys.admins, account),
            repository.addressSetContains(keys.managers, account)
        );
    }

    function getVault(IRepository repository)
    public view
    returns (
        address[]    memory admins,
        address[]    memory managers,
        string       memory name,
        string       memory description,
        uint                balance,
        address[]    memory ownedContracts,
        bool                depositEnabled,
        uint                depositMin,
        uint                depositMax,
        uint                lockUpPeriod,
        uint                entryFee,
        uint                exitFee,
        uint                streamingFee,
        address[]    memory allowedAccounts
    ) {
        Keys memory keys = _generateKeys();
        return (
            repository.getAddressSet    (keys.admins),
            repository.getAddressSet    (keys.managers),
            repository.getString        (keys.name),
            repository.getString        (keys.description),
            repository.getUint          (keys.balance),
            repository.getAddressSet    (keys.ownedContracts),
            repository.getBool          (keys.depositEnabled),
            repository.getUint          (keys.depositMin),
            repository.getUint          (keys.depositMax),
            repository.getUint          (keys.lockUpPeriod),
            repository.getUint          (keys.entryFee),
            repository.getUint          (keys.exitFee),
            repository.getUint          (keys.streamingFee),
            repository.getAddressSet    (keys.allowedAccounts)
        );
    }

    function getToken(IRepository repository)
    public view
    returns (
        string   memory nameToken,
        string   memory symbolToken,
        uint            decimalsToken,
        uint            supplyToken
    ) {
        Keys memory keys = _generateKeys();
        return (
            repository.getString        (keys.nameToken),
            repository.getString        (keys.symbolToken),
            repository.getUint          (keys.decimalsToken),
            repository.getUint          (keys.supplyToken)
        );
    }

    function _generateKeys()
    private view
    returns (Keys memory keys) {
        address msgSender = msg.sender;
        keys = Keys({
            admins:              keccak256(abi.encode("solstice", msgSender, "admins")),
            managers:            keccak256(abi.encode("solstice", msgSender, "managers")),
            name:                keccak256(abi.encode("solstice", msgSender, "name")),
            description:         keccak256(abi.encode("solstice", msgSender, "description")),
            balance:             keccak256(abi.encode("solstice", msgSender, "balance")),
            ownedContracts:      keccak256(abi.encode("solstice", msgSender, "ownedContracts")),
            depositEnabled:      keccak256(abi.encode("solstice", msgSender, "depositEnabled")),
            depositMin:          keccak256(abi.encode("solstice", msgSender, "depositMin")),
            depositMax:          keccak256(abi.encode("solstice", msgSender, "depositMax")),
            lockUpPeriod:        keccak256(abi.encode("solstice", msgSender, "lockUpPeriod")),
            entryFee:            keccak256(abi.encode("solstice", msgSender, "entryFee")),
            exitFee:             keccak256(abi.encode("solstice", msgSender, "exitFee")),
            streamingFee:        keccak256(abi.encode("solstice", msgSender, "streamingFee")),
            allowedAccounts:     keccak256(abi.encode("solstice", msgSender, "allowedAccounts")),
            nameToken:           keccak256(abi.encode("solstice", msgSender, "nameToken")),
            symbolToken:         keccak256(abi.encode("solstice", msgSender, "symbolToken")),
            decimalsToken:       keccak256(abi.encode("solstice", msgSender, "decimalsToken")),
            supplyToken:         keccak256(abi.encode("solstice", msgSender, "supplyToken"))
        });
    }
}

contract Solstice is Ownable, Pausable {
    IRepository      public      repository;
    Factory          public      factory;

    constructor()
    Ownable(msg.sender) {
        factory = new Factory();
    }
}

contract Factory {

}