// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state-router/ProxyStateRouterV1.sol";
import "contracts/polygon/abstract/proxy/proxy-state-history/ProxyStateHistoryV1.sol";
import "contracts/polygon/abstract/access-control/role-state/RoleStateV1.sol";

contract GovernorProxy is ProxyStateRouterV1, ProxyStateHistoryV1, RoleStateV1 {

    error AlreadyInitialized();

    error HasNotBeenInitializedYet();

    function initializedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    function initialized() public view virtual returns (bool) {
        return _bool[initializedKey()];
    }

    function initialize() public virtual {
        _onlynotInitialized();
    }

    function setRoute(address sender, address implementation) public virtual {
        requireRole(roleKey("ROUTER_ROLE"), msg.sender);
        _setRoute(sender, implementation);
    }

    function _onlynotInitialized() internal view virtual {
        if (initialized()) {
            revert AlreadyInitialized();
        }
    }

    function _initialize(implementation) internal virtual override {
        ProxyStateRouterV1._initialize(implementation);
        RoleStateV1._initialize();
        _bool[initializedKey()] = true;
    }

    function _upgrade(address implementation) internal virtual override {
        ProxyStateHistoryV1._upgrade(implementation);
    }
}