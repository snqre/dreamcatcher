// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IAuthenticator {
    error TAG_NOT_FOUND(bytes tag);
}

contract Authenticator is IAuthenticator, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => EnumerableSet.Bytes32Set) public tags;

    constructor() Ownable() {}

    function _convertStrToByt(string memory str)
        private pure returns (bytes memory) {
            return bytes(string);
    }

    function _convertBytToStr(bytes memory byt)
        private pure returns (string memory) {
            return string(byt);
    }

    function _pushTag(address to, string memory tag)
        private {
            tags[to].add(_convertStrToByt(tag));
    }

    function _pullTag(address from, string memory tag)
        private {
            if (!tags[from].contains(_convertStrToByt(tag))) { revert TAG_NOT_FOUND(tag); }
            tags[from].remove(_convertStrToByt(tag));
        } 

    /// testing
    function push(address to, string memory tag)
        public {
            _pushTag(to, tag);
    }

    function pull(address from, string memory tag)
        public {
            _pullTag(from, tag);
    }

    function get(address from, uint spot)
        public view returns (string memory) {
            return _convertBytToStr(tags[from].at(spot));
            
        }
}