// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/state/StateV1.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract OwnableStateV1 is StateV1, Context {

    function ownerKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("OWNER"));
    }

    function owner() public view virtual returns (address) {
        return _address[ownerKey()];
    }

    function renounceOwnership() public virtual {
        _onlyOwner();
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual {
        _onlyOwner();
        _transferOwnership(newOwner);
    }

    function _onlyOwner() internal view virtual {
        require(owner() == _msgSender(), "OwnableStateV1: owner() != _msgSender()");
    }

    function _initialize() internal virtual {
        _transferOwnership(_msgSender());
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner();
        _address[ownerKey()] = newOwner;
        emit Ownable.OwnershipTransferred(oldOwner, newOwner);
    }
    
}