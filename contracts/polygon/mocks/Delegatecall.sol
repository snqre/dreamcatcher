// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/proxy/Base.sol';
import 'contracts/polygon/proxy/Foundation.sol';

contract Car is Base {
    uint public distance = 0;
}

contract Engine is Car {

    /**
    * @dev New roles should be declared at the top of any 
    *      new implementation.
     */
    bytes32 public constant driver = keccak256('driver');

    function move() external virtual {
        _checkRole(driver);
        _move();
    }
    
    function _move() internal virtual {
        distance += 1;
    }
}

contract FasterEngine is Engine {
    bytes32 public constant betterDriver = keccak256('betterDriver');
    

}