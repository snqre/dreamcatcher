// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title PayloadV1
 * @dev A Solidity library for managing and executing payloads.
 */
library PayloadV1 {

    /**
    * @dev Error event indicating a failed call to a target address.
    * @param target The target address of the call.
    * @param dat The data of the call.
    */
    error FailedCallTo(address target, bytes dat);

    /**
    * @dev A struct representing a payload with target, data, success requirement, execution status, and response information.
    */
    struct Payload {
        address _target;
        bytes _dat;
        bool _requireSuccess;
        bool _success;
        bytes _response;
    }

    /**
    * @dev Public pure function to encode the signature of a payload.
    * @param self The Payload struct.
    * @param signature The function signature to encode.
    * @return bytes4 representing the encoded signature of the payload.
    */
    function encodeSignature(Payload memory self, string memory signature) public pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(signature)));
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
    function success(Payload memory self) public pure returns (bool) {
        return self._success;
    }

    /**
    * @dev Public pure function to get the last response data of a payload.
    * @param self The Payload struct.
    * @return bytes memory representing the last response data of the payload.
    */
    function response(Payload memory self) public pure returns (bytes memory) {
        return self._response;
    }

    /**
    * @dev Public function to execute the payload.
    * It calls the target address with the specified data.
    * @param self The storage reference to the Payload struct.
    */
    function execute(Payload storage self) public {
        (bool success, bytes memory response) = address(target(self)).call(dat(self));
        if (requireSuccess(self) && !success) { revert FailedCallTo(target(self), dat(self)); }
        _setSuccess(self, success);
        _setResponse(self, response);
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
        /**
        * abi.encodeWithSelector =>
        * bytes4(keccak256("")),
        * , , , =? args
         */
        self._dat = dat;
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
    * @dev Internal function to set the success status of the payload.
    * @param self The storage reference to the Payload struct.
    * @param success The new success status to set.
    */
    function _setSuccess(Payload storage self, bool success) internal {
        self._success = success;
    }

    /**
    * @dev Internal function to set the response of the payload.
    * @param self The storage reference to the Payload struct.
    * @param response The new response to set.
    */
    function _setResponse(Payload storage self, bytes memory response) internal {
        self._response = response;
    }
}