// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

contract Terminate 
{
    bool private _lock;

    modifier whenNotTerminated()
    {
        _whenNotTerminated();
        _;
    }

    event TERMINATED();

    function _whenNotTerminated()
    internal view
    {
        require
        (
            _lock != true,
            "Terminate: contract terminated"
        );
    }

    function _terminate()
    internal
    {
        _lock = true;
        emit TERMINATED();
    }
}