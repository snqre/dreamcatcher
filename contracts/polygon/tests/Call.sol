// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/libraries/payload/PayloadV1.sol";

contract Called {

    uint256 private _storage_;

    function storage_() external view returns (uint256) {
        return _storage_;
    }

    function helloWorld(uint256 numA, uint256 numB, uint256 numC) external returns (uint256) {
        _storage_ += 1;
        return numA + numB + numC;
    }
}

contract Caller {
    using PayloadV1 for PayloadV1.Payload;

    PayloadV1.Payload private _payload;

    address private _called;

    constructor() {
        _called = address(new Called());
    }
    
    function call() external returns (uint256) {
        _payload.setDat(
            abi.encode(
                _payload.encodeSignature("helloWorld(uint256,uint256,uint256)"),
                100,
                100,
                100
            )
        );
        _payload.setTarget(called());
        _payload.setGas(3000000_000000000000000000);
        _payload.setRequireSuccess(true);
        _payload.setValue(20_000000000000000000);
        _payload.execute();
        return abi.decode(_payload.lastResponse(), (uint256));
    }

    function called() public view returns (address) {
        return _called;
    }
}