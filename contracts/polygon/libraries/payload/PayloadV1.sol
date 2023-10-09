// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Payload Library
 * @dev Library for handling payloads with target, data, value, gas, and execution status information.
 */
library PayloadV1 {

    /**
    * @dev Error event indicating a failed execution of a payload.
    * @param target The target address of the payload.
    * @param data The data of the payload.
    * @param gas The gas specified for the payload execution.
    * @param value The value specified for the payload execution.
    */
    error FailedToExecute(address target, bytes data, uint256 gas, uint256 value);

    /**
    * @dev A struct representing a payload with target, data, value, gas, and execution status information.
    */
    struct Payload {
        address _target;
        bytes _dat;
        bytes _lastResponse;
        uint256 _value;
        uint256 _gas;
        bool _requireSuccess;
        bool _lastSuccess;
    }

    /**
    * @dev Public pure function to get the target address of a payload.
    * @param self The Payload struct.
    * @return address representing the target address of the payload.
    */
    function target(Payload memory self) public pure returns (address) {
        return self._target;
    }

    /**
    * @dev Public pure function to get the data of a payload.
    * @param self The Payload struct.
    * @return bytes memory representing the data of the payload.
    */
    function dat(Payload memory self) public pure returns (bytes memory) {
        return self._dat;
    }

    /**
    * @dev Public pure function to get the value of a payload.
    * @param self The Payload struct.
    * @return uint256 representing the value of the payload.
    */
    function value(Payload memory self) public pure returns (uint256) {
        return self._value;
    }

    /**
    * @dev Public pure function to get the gas limit of a payload.
    * @param self The Payload struct.
    * @return uint256 representing the gas limit of the payload.
    */
    function gas(Payload memory self) public pure returns (uint256) {
        return self._gas;
    }

    /**
    * @dev Public pure function to check if success is required for the next payload execution.
    * @param self The Payload struct.
    * @return bool indicating whether success is required for the next execution.
    */
    function requireSuccess(Payload memory self) public pure returns (bool) {
        return self._requireSuccess;
    }

    /**
    * @dev Public pure function to get the success status of the last payload execution.
    * @param self The Payload struct.
    * @return bool representing whether the last execution was successful.
    */
    function lastSuccess(Payload memory self) public pure returns (bool) {
        return self._lastSuccess;
    }

    /**
    * @dev Public pure function to get the last response data of a payload.
    * @param self The Payload struct.
    * @return bytes memory representing the last response data of the payload.
    */
    function lastResponse(Payload memory self) public pure returns (bytes memory) {
        return self._lastResponse;
    }

    /**
    * @dev Public pure function to encode the signature of a payload.
    * @param signature The function signature to encode.
    * @return bytes4 representing the encoded signature of the payload.
    */
    function encodeSignature(Payload memory self, string memory signature) public pure returns (bytes4) {
        return bytes4(keccak256(bytes(signature)));
    }

    /**
    * @dev Public function to execute the payload.
    * It calls the target address with the specified gas, value, and data.
    * @param self The storage reference to the Payload struct.
    */
    function execute(Payload storage self) public {
        (bool success, bytes memory response) = address(target(self)).call{gas: gas(self), value: value(self)}(dat(self));
        if (requireSuccess(self) && !success) {
            revert FailedToExecute(target(self), dat(self), gas(self), value(self));
        }
        _setLastSuccess(self, success);
        _setLastResponse(self, response);
    }

    /**
    * @dev Public function to set the target address of the payload.
    * @param self The storage reference to the Payload struct.
    * @param target The new target address to set.
    */
    function setTarget(Payload storage self, address target) public {
        self._target = target;
    }

    /**
    * @dev Public function to set the data of the payload.
    * @param self The storage reference to the Payload struct.
    * @param dat The new data to set.
    */
    function setDat(Payload storage self, bytes memory dat) public {
        self._dat = dat;
    }

    /**
    * @dev Public function to set the value of the payload.
    * @param self The storage reference to the Payload struct.
    * @param value The new value to set.
    */
    function setValue(Payload storage self, uint256 value) public {
        self._value = value;
    }

    /**
    * @dev Public function to set the gas limit of the payload.
    * @param self The storage reference to the Payload struct.
    * @param gas The new gas limit to set.
    */
    function setGas(Payload storage self, uint256 gas) public {
        self._gas = gas;
    }

    /**
    * @dev Public function to set whether the payload execution requires success.
    * @param self The storage reference to the Payload struct.
    * @param requireSuccess Boolean indicating whether success is required.
    */
    function setRequireSuccess(Payload storage self, bool requireSuccess) public {
        self._requireSuccess = requireSuccess;
    }

    /**
    * @dev Internal function to set the last success status of the payload.
    * @param self The storage reference to the Payload struct.
    * @param success The new success status to set.
    */
    function _setLastSuccess(Payload storage self, bool success) private {
        self._lastSuccess = success;
    }

    /**
    * @dev Internal function to set the last response of the payload.
    * @param self The storage reference to the Payload struct.
    * @param response The new response to set.
    */
    function _setLastResponse(Payload storage self, bytes memory response) internal {
        self._lastResponse = response;
    }


}