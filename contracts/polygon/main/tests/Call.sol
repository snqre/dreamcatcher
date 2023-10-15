// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/libraries/payload/PayloadV1.sol";

/**
 * @dev Contract `Called` with a private uint256 state variable and functions to retrieve and increase the stored number.
 */
contract Called {

    /**
    * @dev Private state variable to store a uint256 number.
    */
    uint256 private _number;

    /**
    * @dev Public function to retrieve the stored uint256 number.
    * @return uint256 representing the stored number.
    */
    function number() public view returns (uint256) {
        return _number;
    }

    /**
    * @dev Public function to increase the stored uint256 number by a specified value.
    * @param value The value to increase the number by.
    */
    function increaseNumber(uint256 value) public returns (uint256) {
        _increaseNumber(value);
        return _number;
    }

    /**
    * @dev Internal function to increase the stored uint256 number by a specified value.
    * @param value The value to increase the number by.
    */
    function _increaseNumber(uint256 value) internal {
        _number += value;
    }
}

/**
 * @dev Contract `Caller` interacts with another contract `Called` using the PayloadV1 library.
 */
contract Caller {

    /**
    * @dev Import and use the PayloadV1 library for the Payload struct.
    */
    using PayloadV1 for PayloadV1.Payload;

    /**
    * @dev Private instance of the Payload struct from the PayloadV1 library.
    */
    PayloadV1.Payload private _payload;

    /**
    * @dev Private variable to store the address of the `Called` contract.
    */
    address private _called;

    /**
    * @dev Constructor to initialize the contract. It sets the `_called` address to a new instance of the `Called` contract.
    */
    constructor() {
        _called = address(new Called());
    }

    /**
    * @dev Public function to get the address of the `Called` contract.
    * @return address representing the address of the `Called` contract.
    */
    function called() public view returns (address) {
        return _called;
    }

    /**
    * @dev Public function to increase the number in the `Called` contract by a specified value.
    * @param value The value by which to increase the number.
    * @return uint256 representing the updated number in the `Called` contract.
    */
    function increaseNumberOfCalledBy(uint256 value) public returns (uint256) {
        return _call(abi.encodeWithSelector(_payload.encodeSignature("increaseNumber(uint256))"), value));
    }

    /**
    * @dev Internal function to call a target address with the specified data using the internal payload.
    * @param dat The data to be used in the call.
    * @return uint256 representing the response from the target address.
    */
    function _call(bytes memory dat) internal returns (uint256) {
        _payload.setTarget(_called);
        _payload.setDat(dat);
        _payload.setRequireSuccess(true);
        _payload.execute();
        return abi.decode(_payload.response(), (uint256));
    }
}