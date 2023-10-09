// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library PayloadV1 {

    error FailedCallTo(address target, bytes dat);

    struct Payload {
        address _target;
        bytes _dat;
        bool _requireSuccess;
        bool _success;
        bytes _response;
    }

    function encodeSignature(Payload memory self, string memory signature) public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(signature)));
    }

    function target(Payload memory self) public pure returns (address) {
        return self._target;
    }

    function dat(Payload memory self) public pure returns (bytes memory) {
        return self._dat;
    }

    function requireSuccess(Payload memory self) public pure returns (bool) {
        return self._requireSuccess;
    }

    function success(Payload memory self) public pure returns (bool) {
        return self._success;
    }

    function response(Payload memory self) public pure returns (bytes memory) {
        return self._response;
    }

    function execute(Payload storage self) public {
        (bool success, bytes memory response) = address(target(self)).call(dat(self));
        if (requireSuccess(self) && !success) { revert FailedCallTo(target(self), dat(self)); }
        _setSuccess(self, success);
        _setResponse(self, response);
    }

    function setTarget(Payload storage self, address target) public {
        self._target = target;
    }

    function setDat(Payload storage self, bytes memory dat) public {
        /**
        * abi.encodeWithSelector =>
        * bytes4(keccak256("")),
        * , , , =? args
         */
        self._dat = dat;
    }

    function setRequireSuccess(Payload storage self, bool requireSuccess) public {
        self._requireSuccess = requireSuccess;
    }

    function _setSuccess(Payload storage self, bool success) internal {
        self._success = success;
    }

    function _setResponse(Payload storage self, bytes memory response) internal {
        self._response = response;
    }
}