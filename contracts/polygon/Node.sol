// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Node {
    bytes32 internal constant NAMESPACE = keccak256('message.node');

    struct Storage {
        string message;
    }

    function getStorage() internal pure returns (Storage storage s) {
        bytes32 location = NAMESPACE;
        assembly {
            s.slot := location
        }
    }

    function setMessage(string calldata msg) external {
        Storage storage s = getStorage();
        s.message = msg;
    }

    function getMessage() external view returns (string memory) {
        return getStorage().message;
    }
}