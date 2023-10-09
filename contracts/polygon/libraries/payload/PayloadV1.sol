// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library PayloadV1 {

    error FailedCallTo(address target, bytes dat, uint256 gas, uint256 value);

    struct Payload {
        address _target;
        bytes _dat;
        uint256 _gas;
        uint256 _value;
        bool _requireSuccess;
        bool _success;
        bytes _response;
    }

    function target(Payload memory self) public pure returns (address) {
        return self._target;
    }

    function dat(Payload memory self) public pure returns (bytes memory) {
        return self._dat;
    }

    function gas(Payload memory self) public pure returns (uint256) {
        return self._gas;
    }

    function value(Payload memory self) public pure returns (uint256) {
        return self._value;
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
        (bool success, bytes memory response) = address(target(self)).call{gas: gas(self), value: value(self)}(dat(self));
        if (requireSuccess(self) && !success) { revert FailedCallTo(target(self), dat(self), gas(self), value(self)); }
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

    function setGas(Payload storage self, uint256 gas) public {
        self._gas = gas;
    }

    function setValue(Payload storage self, uint256 value) public {
        self._value = value;
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