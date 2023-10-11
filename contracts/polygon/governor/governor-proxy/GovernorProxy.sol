// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state/ProxyStateV2.sol";

contract GovernorProxy is ProxyStateV2 {

    /** ProxyStateV2 */

    function defaultImplementation() public view virtual override returns (address) {
        /** ... @dev Hardcoded first implementation because the proxy lacks upgrade feature ... */
        return ;
    }
}