// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/deps/openzeppelin/utils/Context.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/access/AccessControlEnumerable.sol";
import "contracts/polygon/Terminate.sol";
import "contracts/polygon/interfaces/IRepository.sol";
import "contracts/polygon/Repository.sol";

contract State {
    mapping(bytes32 => bytes) private _storage;

    function setBytes()
}

contract TerminalLogicV001 is
AccessControlEnumerable,
ReentrancyGuard,
Terminate,
Pausable
{
    bytes32 constant ROUTERS = keccak256(abi.encode("ROUTERS"));

    IRepository public repository;

    event DEPLOYED_ROUTER
    (
        string indexed message,
        string indexed name,
        address indexed router
    );

    constructor()
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function routers()
    external view
    returns (address[] memory)
    {
        return repository.getAddressSet(ROUTERS);
    }

    function deployRouter
    (
        string memory message,
        string memory name,
        string memory module,
        
    )
    external
    whenNotTerminated
    onlyRole(DEFAULT_ADMIN_ROLE)
    whenNotPaused
    returns (address)
    {

    }
}