// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface IAuthenticator {
    error TAG_NOT_FOUND(bytes tag);
}

contract Authenticator is IAuthenticator, Ownable {

    mapping(address => string[]) public tags;

    constructor() Ownable(msg.sender) {}

    function grant(address to, string memory tag)
        public {
        tags[to].push(tag);
    }
    
    function revoke(address from, string memory tag)
        public {
        for (uint i = 0; i < tags[from].length; i++) {
            string memory selected = tags[from][i];
            if (keccak256(abi.encodePacked(selected)) == keccak256(abi.encodePacked(tag))) {
                tags[from][i].pop();
                break;
            }
        }
    }
}