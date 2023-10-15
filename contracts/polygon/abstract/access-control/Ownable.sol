// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract Ownable is Storage, Context {

    /**
    * @dev Emitted when ownership of the contract is transferred.
    * @param previousOwner The address of the previous owner.
    * @param newOwner The address of the new owner.
    */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Returns the current owner.
    * @return address The current owner.
    */
    function owner() public view virtual returns (address) {
        return _address[_keyOwner()];
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
    * @dev Returns the key for the owner in the storage.
    * @return bytes32 The key for the owner in the storage.
    */
    function _keyOwner() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("owner"));
    }

    /**
    * @dev Modifier that throws if called by any account other than the owner.
    */
    function _onlyOwner() internal view virtual {
        require(owner() == _msgSender(), "owner != _msgSender");
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
        _address[_keyOwner()] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}