// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Node {
    bytes32 internal constant LOCATION = keccak256('terminal.module');

    struct Storage {
        string something;
        uint alsoSomething;
        uint[200] somethingElse;
    }

    function s() internal pure returns (Storage storage s) {
        bytes32 location = LOCATION;
        assembly {
            s.slot := location
        }
    }

    function setSomething(uint newSomething) external {
        Storage storage s = s();
        s.alsoSomething = newSomething;
    }

    function getSomething() external view returns (uint) {
        return s().alsoSomething;
    }
}