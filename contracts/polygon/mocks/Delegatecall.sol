// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/proxy/lite/ProxyLite.sol";
import "contracts/polygon/proxy/lite/DefaultImplementationLite.sol";

contract Car is ProxyLite {}

/** Assume engine as the first implementation. */
contract Engine is DefaultImplementationLite {

    /** 
    * @dev It is preferible to use public view for reading
    *      storage variables. Instead of accessing it
    *      directly through decoding the storage. As such
    *      every key will typically come with its own
    *      public view function.
    */
    function distance() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____distance()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____distance()], (uint));
    }

    function upgrade(address newImplementation) public virtual {
        _upgrade(newImplementation);
    }

    function move() public virtual {
        _move();
    }

    /**
    * @dev We prefix storage location with ____.
    *      Other properties can be encoded into the location
    *      for example an account or the id of the distance
    *      that we are trying to search for.
    *
    * NOTE: Because this is a form of mapping, it is often more
    *       efficient that arrays and we can map together many
    *       types of datatypes and information to retrieve a
    *       unique storage location.
     */
    function ____distance() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("DISTANCE"));
    }
    
    function _move() internal virtual {
        uint distance = distance();
        uint speed = 235;
        uint newDistance = distance + speed;
        StorageLite._bytes[____distance()] = abi.encode(newDistance);
    }
}

/** We can now install a faster engine. */
contract FasterEngine is Engine {
    function _move() internal virtual override {
        uint distance = Engine.distance();
        uint speed = 600;
        uint newDistance = distance + speed;
        StorageLite._bytes[Engine.____distance()] = abi.encode(newDistance);
    }
}

/**
* @dev Can now upgrade to an even faster engine.
* NOTE: It's usually better to inherit the contract that is being
*       upgraded as this will reduce the risk of any
*       conflicts.
*
* NOTE: It is also a good idea to explicitly state from what
*       inherited contract the function, is being called from
*       as there can be several.
*
*       * StorageLite._bytes
*       * Engine.____distance()
*       
*       This mutability comes with a lot more things to pay
*       attention to and the requirement to lock the 
*       upgradeability behind shared access control or
*       immutable logic.
 */
contract HyperEngine is Engine {
    function moveTwice() public virtual {
        HyperEngine._move();
        HyperEngine._move();
    }

    function _move() internal virtual override {
        uint distance = Engine.distance();
        uint speed = 900;
        uint newDistance = distance + speed;
        StorageLite._bytes[Engine.____distance()] = abi.encode(newDistance);
    }
}