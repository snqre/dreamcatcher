// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/abstract/ProxyState.sol";

import "contracts/polygon/abstract/State.sol";

/** Proxy compatible version of Ownable.
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

/** Proxy compatible version of Pausable.
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */

/**
 * NOTE WARNING: DO NOT MODIFY STORAGE.
 * NOTE WARNING: DO NOT USE CONSTRUCTOR.
 * NOTE WARNING: RESERVED: _address  -> $
 * NOTE WARNING: RESERVED: _address  -> $owner
 * NOTE WARNING: RESERVED: _bool     -> $initialized
 * NOTE WARNING: RESERVED: _bool     -> $paused
 */
contract ProxyStateOwnable is ProxyState, Context {

    /** Events. */

    event Initialized(address indexed account);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address indexed account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address indexed account);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
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

    /** External. */

    /**
    * @dev To be called immediately after deployment by Terminal (within the same transaction).
    * Initializes the contract in unpaused state.
     */
    function initialize() external {
        bytes32 location = keccak256(abi.encode("$initialized"));
        require(!_bool[location], "ProxyStateOwnable: already initialized");
        _transferOwnership(_msgSender());
        location = keccak256(abi.encode("$paused"));
        _bool[location] = false;
        location = keccak256(abi.encode("$initialized"));
        _bool[location] = true;
        emit Initialized(_msgSender());
    }

    /**
    * @dev Upgrade to a new implementation (see documentation on how to do this safely.)
    * SHOULD only upgrade when paused.
     */
    function upgrade(address implementation) external onlyOwner whenPaused {
        _upgrade(implementation);
    }

    /** Public View. */

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        bytes32 location = keccak256(abi.encode("$owner"));
        return _address[location];
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        bytes32 location = keccak256(abi.encode("$paused"));
        return _bool[location];
    }

    /** Public. */

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "ProxyStateOwnable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
    * @dev Pause
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
    * @dev Unpause
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /** Internal View. */

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view {
        require(owner() == _msgSender(), "ProxyStateOwnable: caller is not the owner");
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view {
        require(!paused(), "ProxyStateOwnable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view {
        require(paused(), "ProxyStateOwnable: not paused");
    }

    /** Internal. */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        bytes32 location = keccak256(abi.encode("$owner"));
        address oldOwner = _address[location];
        _address[location] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal whenNotPaused {
        bytes32 location = keccak256(abi.encode("$paused"));
        _bool[location] = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal whenPaused {
        bytes32 location = keccak256(abi.encode("$paused"));
        _bool[location] = false;
        emit Unpaused(_msgSender());
    }
}