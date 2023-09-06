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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

/**
    _bytes      "solstice", msg.sender, "metadata"
    _bytes      "solstice", msg.sender, "settings"
 */
contract Safeguard {
    IRepository public repository;

    function getCopiedMetadata()
    public view
    returns (
        address[] memory admins,
        address[] memory managers,
        address[] memory depositors,
        string memory name,
        string memory description,
        address[] memory contracts
    ) {
        bytes memory object = repository.getBytes(
            _metadata()
        );
        (
            admins,
            managers,
            depositors,
            name,
            description,
            contracts
        ) = abi.decode(
            object,
            (
                address[],
                address[],
                address[],
                string,
                string,
                address[]
            )
        );
        return (
            admins,
            managers,
            depositors,
            name,
            description,
            contracts
        );
    }

    function getCopiedSettings()
    public view
    returns (
        bool isPaused,
        bool isWhitelisted,
        uint minDeposit,
        uint maxDeposit,
        uint lockUpPeriod,
        uint feeManagement,
        uint feeDeposit,
        uint feeWithdraw,
        address[] memory whitelist
    ) {
        bytes memory object = repository.getBytes(
            _settings()
        );
        (
            isPaused,
            isWhitelisted,
            minDeposit,
            maxDeposit,
            lockUpPeriod,
            feeManagement,
            feeDeposit,
            feeWithdraw,
            whitelist
        ) = abi.decode(
            object,
            (
                bool,
                bool,
                uint,
                uint,
                uint,
                uint,
                uint,
                uint,
                address[]
            )
        );
        return (
            isPaused,
            isWhitelisted,
            minDeposit,
            maxDeposit,
            lockUpPeriod,
            feeManagement,
            feeDeposit,
            feeWithdraw,
            whitelist
        );
    }

    function copyMetadata(
        address[] memory admins,
        address[] memory managers,
        address[] memory depositors,
        string memory name,
        string memory description,
        address[] memory contracts
    ) public {
        bytes memory object = abi.encode(
            admins,
            managers,
            depositors,
            name,
            description,
            contracts
        );
        repository.setBytes(
            _metadata(), 
            object
        );
    }

    function copySettings(
        bool isPaused,
        bool isWhitelisted,
        uint minDeposit,
        uint maxDeposit,
        uint lockUpPeriod,
        uint feeManagement,
        uint feeDeposit,
        uint feeWithdraw,
        address[] memory whitelist
    ) public {
        bytes memory object = abi.encode(
            isPaused,
            isWhitelisted,
            minDeposit,
            maxDeposit,
            lockUpPeriod,
            feeManagement,
            feeDeposit,
            feeWithdraw,
            whitelist
        );
        repository.setBytes(
            _settings(),
            object
        );
    }

    function _metadata()
    private view
    returns (bytes32) {
        return keccak256(
            abi.encode(
                "solstice", 
                msg.sender, 
                "metadata"
            )
        );
    }

    function _settings()
    private view
    returns (bytes32) {
        return keccak256(
            abi.encode(
                "solstice",
                msg.sender,
                "settings"
            )
        );
    }
}

contract SolsticeVault {

    constructor() {

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