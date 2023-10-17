// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/deps/openzeppelin/utils/Context.sol";
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/access/AccessControlEnumerable.sol";
import "contracts/polygon/Router.sol";

contract Terminal is
AccessControlEnumerable,
ReentrancyGuard,
Pausable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _routers;
    EnumerableSet.AddressSet private _routersTerminated;

    
}

contract Terminal2 is
AccessControlEnumerable,
ReentrancyGuard,
Pausable
{
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _routers;
    EnumerableSet.AddressSet private _routersTerminated;

    event DEPLOYED_ROUTER
    (
        string indexed name,
        string indexed description,
        address indexed router
    );

    constructor()
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function deployRouter
    (
        string memory name,
        string memory description
    )
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    whenNotPaused
    returns (address)
    {
        address router = address(new Router(name, description));
        _routers.add(router);
        emit DEPLOYED_ROUTER(name, description, router);
        return router;
    }

    function terminateRouter(address router)
    public
    onlyRole(DEFAULT_ADMIN_ROLE)
    whenNotPaused
    {
        require
        (
            _routers.contains(router),
            "Terminal: router not found"
        );


    }

    
}