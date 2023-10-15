// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";

/**
* ownerKey => address
 */
abstract contract Ownable is Storage {

    /**
    * @dev Emitted when ownership of the contract is transferred.
    * @param oldOwner The address of the old owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /**
    * @dev Returns the key for the owner in the storage mapping.
    * @return The key for the owner.
    */
    function ownerKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("OWNER"));
    }

    /**
    * @dev Returns the current owner of the contract.
    * @return The address of the current owner.
    */
    function owner() public view virtual returns (address) {
        return _address[_keyOwner()];
    }

    /**
    * @dev Renounces ownership, leaving the contract without an owner.
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
    * @dev Throws if called by any account other than the owner.
    */
    function _onlyOwner() internal view virtual {
        require(owner() == msg.sender, "owner() != msg.sender");
    }

    /**
    * @dev Initializes the contract by setting the owner to the sender.
    * Note: This function can only be called once during deployment.
    */
    function _initialize() internal virtual {
        _transferOwnership(msg.sender);
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