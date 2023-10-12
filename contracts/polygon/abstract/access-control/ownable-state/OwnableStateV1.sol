// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract OwnableStateV1 is StateV1, Context {

    /**
    * @dev Emitted when ownership of the contract is transferred.
    * @param previousOwner The address of the previous owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Returns the key for the owner in the storage.
    * @return bytes32 The key for the owner in the storage.
    */
    function ownerKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("OWNER"));
    }

    /**
    * @dev Returns the current owner.
    * @return address The current owner.
    */
    function owner() public view virtual returns (address) {
        return _address[ownerKey()];
    }

    /**
    * @dev Renounces ownership, leaving the contract without an owner.
    * Can only be called by the current owner.
    */
    function renounceOwnership() public virtual {
        _onlyOwner();
        _transferOwnership(address(0));
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public virtual {
        _onlyOwner();
        _transferOwnership(newOwner);
    }

    /**
    * @dev Modifier that throws if called by any account other than the owner.
    */
    function _onlyOwner() internal view virtual {
        require(owner() == _msgSender(), "OwnableStateV1: owner() != _msgSender()");
    }

    /**
    * @dev Initializes the contract, setting the initial owner.
    */
    function _initialize() internal virtual {
        _transferOwnership(_msgSender());
    }

    /**
    * @dev Transfers ownership of the contract to a new address.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner();
        _address[ownerKey()] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}