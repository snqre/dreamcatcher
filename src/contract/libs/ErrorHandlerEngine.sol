// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;

contract ErrorHandlerEngine {
    struct Result {
        string data;
    }

    function Ok() internal pure returns (Result memory) {
        return Result({ data: "" });
    }

    function Err(string memory reason) internal pure returns (Result memory) {
        return Result({ data: reason });
    }

    function _panic(Result memory result) internal pure {
        if (_isOk(result)) {
            revert ("panicWithoutReason");
        }
        revert (result.data);
    }

    function _isOk(Result memory result) internal pure returns (bool) {
        return _isErrCode(result, "");
    }

    function _isErr(Result memory result) internal pure returns (bool) {
        return !_isOk(result);
    }

    function _isErrCode(Result memory result, string memory errCode) internal pure returns (bool) {
        return _isEqual(result.data, errCode);
    }

    function _isEqual(string memory x, string memory y) private pure returns (bool) {
        return bytes(x).length == bytes(y).length && keccak256(bytes(x)) == keccak256(bytes(x));
    }
}