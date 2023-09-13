// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/access/Ownable.sol";

import "contracts/polygon/interfaces/IConState.sol";
import "contracts/polygon/interfaces/IConRouter.sol";
import "contracts/polygon/libraries/LibMatch.sol";
import "contracts/polygon/ConState.sol";

abstract contract AbsConRouter is IConRouter, Ownable
{
    struct Implementation
    {
        string name;
        address logic;
        uint256 version;
    }

    struct Self
    {
        ConState stateImpl;
        Implementation[] impls;
    }

    IConRouter state;

    bytes32 constant $ = keccak256("$");

    constructor
    (
        address myState,
        address implState
    )
    {
        /// set state and deploy implementation state
        state = IConRouter(myState);
        Self memory self = access();
        self.stateImpl = new ConState(address(this));
        _store(self);
    }

    function access() public view returns (Self memory)
    {
        return abi.decode(state.access($), (Self));
    }

    function myState() public view returns (address)
    {
        return address(state);
    }

    function implementationState() public view returns (address)
    {
        Self memory self = access();
        return address(self.stateImpl);
    }

    function latestVersion() public view returns (uint256)
    {
        Self memory self = access();
        return self.impls.length - 1;
    }

    function implementation(uint index) public view returns
    (
        string memory name,
        address logic,
        uint256 version
    )
    {
        Self memory self = access();
        return
        (
            self.impls[index].name,
            self.impls[index].logic,
            self.impls[index].version
        );
    }

    function latestImplementation() public view returns
    (
        string memory name,
        address logic,
        uint256 version
    )
    {
        Self memory self = access();
        uint index = latestVersion();
        return
        (
            self.impls[index].name,
            self.impls[index].logic,
            self.impls[index].version
        );
    }

    function upgrade
    (
        string memory name,
        address newImplementation
    )
    public
    {
        Self memory self = access();

        for (uint i = 0; i < self.impls.length; i++)
        {
            require
            (
                !LibMatch.isMatchString(name, self.impls[i].name),
                "AbsConRouter: name is already in use"
            );
        }

        uint lastIndex = latestVersion();

        self.impls.push
        (
            Implementation
            ({
                name: name,
                logic: newImplementation,
                version: lastIndex + 1
            })
        );

        self.stateImpl.upgrade(newImplementation);

        emit Upgrade(newImplementation);
    }

    function _store(Self memory self) private
    {
        state.store($, abi.encode(self));
    }
}