// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IPayloadLite {
    event TargetUpdated(address indexed previousTarget, address indexed newTarget);

    event DataUpdated(bytes indexed previousData, bytes indexed newData);

    event LastResponseUpdated(bytes indexed previousResponse, bytes indexed newResponse);

    function target() external view returns (address);

    function data() external view returns (bytes memory);

    function lastResponse() external view returns (bytes memory);
}