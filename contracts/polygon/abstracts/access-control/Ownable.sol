// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract Ownable is StorageLite {
    address internal _owner;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    function owner() external view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) external virtual {
        _onlyOwner();
        _transferOwnership(newOwner);
    }

    function renounceOwnership() external virtual {
        _onlyOwner();
        _transferOwnership(address(0));
    }

    function _onlyOwner() internal view virtual {
        require(_isOwner(msg.sender));
    }

    function _isOwner(address account) internal view virtual returns (bool) {
        return account == _owner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}