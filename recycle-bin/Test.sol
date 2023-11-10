// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Yul {
    uint x;
    uint cake;
    string bake = 'helloWorld';
    uint128 some;   // same slot
    uint128 some2;  // same slot

    function setx(uint v) public {
        assembly {
            sstore(0, v)
        }
    }

    function getx() external view returns (uint r) {
        assembly {
            r := x.slot          // gives slot location
            r := sload(x.slot)   // get the value at slot
            r := sload(bake.slot)
            r := 900
        }
    }

    
    

}