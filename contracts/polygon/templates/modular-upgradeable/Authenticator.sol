// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface IAuthenticator {
    error TAG_NOT_FOUND(bytes tag);
}

contract Authenticator is IAuthenticator, Ownable {

    mapping(address => string[]) public tags;

    constructor() Ownable(msg.sender) {
        _grant(msg.sender, "can-grant-role");
        _grant(msg.sender, "can-grant-role");
        _grant(msg.sender, "can-grant-role");
        _revoke(msg.sender, "can-revoke-role");
        _revoke(msg.sender, "can-revoke-role");
    }

    function _grant(address to, string memory tag)
        public {
        tags[to].push(tag);
    }
    
    function _revoke(address from, string memory tag)
        public
        returns (bool) {
        bool success;
        for (uint i = 0; i < tags[from].length; i++) {
            string memory selected = tags[from][i];
            if (keccak256(abi.encodePacked(selected)) == keccak256(abi.encodePacked(tag))) {
                tags[from][i].pop();
                success = true;
                break;
            }
        }

        return success;
    }
    
    function authenticate(address from, string memory tag)
        public
        returns (bool) {
        bool success = revoke(from, tag);
        require(success, "INSUFFICIENT_AUTHORIZATION");
    }

    function grant(address to, string memory tag)
        public {
        authenticate(msg.sender, "can-grant-role");
        _grant(to, tag);
    }
    
    function revoke(address from, string memory tag)
        public {
        authenticate(msg.sender, "can-revoke-role");
    }
}