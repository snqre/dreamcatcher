// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

/**
* @dev The reason we need a deployer is because the initialize function
*      does not have knowledge of who the deployer is because we have to
*      disable the constructor of the proxy on deployment.
*      The solution is to deploy and call initialize() within the same
*      transaction, to reduce the risk of front running.
*
* @dev We do this only for the Terminal which will then be responsable
*      for deploying other proxies.
 */
contract Deployer is Context {

    /** State Variables. */

    address public deployed;

    /** Constructor. */

    /**
    * @dev Deploys the new proxy, initializes it becoming the owner
    *      then transfers ownership to the deployer of the proxy
     */
    constructor() {
        deployed = address(new ProxyStateOwnableContract());
        IProxyStateOwnable(deployed).initialize();
        IProxyStateOwnable(deployed).transferOwnership(_msgSender());
    }
}