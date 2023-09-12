// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/Terminate.sol";

contract TerminateTimer is Terminate
{
    uint64 private _timestamp;

    constructor(uint64 duration)
    {
        _timestamp = uint64(block.timestamp);
        _timestamp += duration;
    }

    function _whenNotTerminated()
    internal view override(Terminate)
    {
        require
        (
            block.timestamp < _timestamp,
            "TerminateTimer: contract terminated"
        );
    }

    function _terminate()
    internal override(Terminate)
    {
        /// @dev does nothing
    }
}