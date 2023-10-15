// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

abstract contract Role is Storage {

    using EnumerableSet for EnumerableSet.AddressSet;

    event Granted(address indexed account);

    event Revoked(address indexed account);

    function name() public view virtual returns (string memory) {

    }

    function admin() public view virtual returns (address) {

    }

    function members(uint256 memberId) public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage members = _addressSet[membersKey()];
        return members.at(memberId);
    }

    function membersLength() public view virtual returns (uint256) {
        EnumerableSet.AddressSet storage members = _addressSet[membersKey()];
        return members.length();
    }

    function grant(address account) public virtual {

    }

    function _nameKey() internal pure virtual returns (bytes32) {
        
    }

    function _membersKey() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("members"));
    }

    
}