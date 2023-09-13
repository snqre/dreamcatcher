// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/access/Ownable.sol";

import "contracts/polygon/interfaces/IConState.sol";

abstract contract AbsConState is IConState, Ownable
{
    address public implementation;

    mapping(bytes32 => bytes) public storage_;

    modifier onlyImplementation()
    {
        require(msg.sender == implementation);
        _;
    }

    constructor(address admin) Ownable(admin) {}

    function access(bytes32 location) 
    external view virtual 
    returns (bytes memory)
    {
        return storage_[location];
    }

    function store
    (
        bytes32 location,
        bytes memory data
    ) 
    external virtual
    onlyImplementation
    {
        storage_[location] = data;
        emit Update
        (
            location,
            data
        );
    }

    function upgrade(address newImplementation)
    external virtual
    onlyOwner
    {
        implementation = newImplementation;
        emit Upgrade(newImplementation);
    }
}