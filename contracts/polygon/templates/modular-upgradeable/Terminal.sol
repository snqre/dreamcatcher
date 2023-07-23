// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/templates/modular-upgradeable/__Calls.sol";

contract Terminal {
    mapping(string => address) private _cache;

    address public hub;
    constructor(address hub_) {
        hub = hub_;
    }

    function getRouters()
        public view
        returns (address[] memory) {
        return IHub(hub).getRouters(address(this));
    }

    function connect(string memory signature, bytes memory args)
    public
    returns (bytes memory) {
        bool success;
        bytes memory response;
        address contract_;
        if (_cache[signature] != address(0)) {
            (success, response) = _cache[signature].call(abi.encodeWithSignature(signature, args));
            if (!success) { _cache[signature] = address(0); }
        }
        if (!success) {
            address[] memory routers = getRouters();
            (success, response, contract_) = __Calls.call(routers, signature, args);
            if (success) { _cache[signature] = contract_; }
        }
        require(success, "Terminal: failed to find signature");
        return response;
    }
}