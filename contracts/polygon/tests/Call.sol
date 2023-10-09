// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/libraries/payload/PayloadV1.sol";

contract Called {

    uint256 private _storage_;

    function storage_() external view returns (uint256) {
        return _storage_;
    }

    function helloWorld(uint256 numA, uint256 numB, uint256 numC) external returns (uint256) {
        return numA + numB + numC;
    }
}

contract Caller {
    using PayloadV1 for PayloadV1.Payload;

    PayloadV1.Payload private _payload;

    Called private _called;

    constructor() {
        _called = new Called();  // Create an instance of Called
    }
    
    function callHelloWorld(bytes memory dat) external returns (uint256) {
        _payload.setTarget(address(_called));
        _payload.setDat(abi.encodeWithSelector(_payload.encodeSignature("helloWorld(uint256,uint256,uint256)"), 100, 100, 100));
        _payload.setRequireSuccess(true);
        _payload.execute();
        return abi.decode(_payload.response(), (uint256));
    }

    function callHelloWorld2() external returns (uint256) {
        bytes memory data = abi.encodeWithSelector(
                bytes4(keccak256("helloWorld(uint256,uint256,uint256)")), 
                15000, 10000, 5000
            );
        (bool success, bytes memory response) 
        = address(_called).call(
            data
        );
        
        /**
        (bool success, bytes memory response) 
        = address(_called).call(
            abi.encodeWithSignature(
                "helloWorld(uint256,uint256,uint256)", 
                abi.encode(1000, 500, 5000)
            )
        );
        */

        return abi.decode(response, (uint256));
    }

    function getCalledStorage() external view returns (uint256) {
        return _called.storage_();
    }
}