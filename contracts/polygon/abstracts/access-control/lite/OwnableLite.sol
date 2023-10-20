// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

/** Adapted from openzeppelin's Ownable.sol */
abstract contract OwnableLite is StorageLite, Context {
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____owner()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____owner()], (address));
    }

    function renounceOwnership() public virtual {
        _onlyOwner();
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual {
        _onlyOwner();
        require(newOwner != address(0), "OwnableLite: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function ____owner() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("OWNER"));
    }

    function _onlyOwner() internal view virtual {
        require(owner() == _msgSender(), "OwnableLite: caller is not the owner");
    }

    function _initialize(address initialOwner) internal virtual {
        _transferOwnership(initialOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address previousOwner = owner();
        _bytes[____owner()] = abi.encode(newOwner);
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}