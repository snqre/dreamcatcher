// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/StorageLite.sol";

abstract contract Ownable is StorageLite {

    /**
    * @notice Event emitted when ownership of the contract is transferred.
    * @param sender The address triggering the event.
    * @param oldOwner The address of the previous owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(address indexed sender, address indexed oldOwner, address indexed newOwner);

    /**
    * @notice Returns the address of the current owner.
    * @return The address of the owner.
    */
    function owner() public view virtual returns (address) {
        return abi.decode(_bytes[____owner()], (address));
    }

    /**
    * @notice Renounces ownership, making the contract ownerless.
    */
    function renounceOwnership() public virtual {
        _onlyOwner();
        _transferOwnership(address(0));
    }

    /**
    * @notice Transfers ownership of the contract to a new address.
    * @param newOwner The address of the new owner.
    */
    function transferOwnership(address newOwner) public virtual {
        _onlyOwner();
        _transferOwnership(newOwner);
    }

    /**
    * @dev Internal function to acceess owner storage.
    */
    function ____owner() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("OWNER"));
    }

    /**
    * @dev Internal function to check that the caller is the owner.
    */
    function _onlyOwner() internal view virtual {
        require(owner() == msg.sender && owner() != address(0), "OwnableLite: owner() != msg.sender || owner() == address(0)");
    }

    /**
    * @dev Internal function to initialize the contract and set the owner.
    */
    function _initialize() internal virtual {
        _transferOwnership(msg.sender);
    }

    /**
    * @dev Internal function to transfer ownership of the contract.
    * @param newOwner The address of the new owner.
    */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner();
        _bytes[____owner()] = abi.encode(newOwner);
        emit OwnershipTransferred(msg.sender, oldOwner, newOwner);
    }
}