// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/templates/modular-upgradeable/__Calls.sol";

contract Terminal {
    mapping(string => address) private _cache;

    string public name_;
    address public hub;
    constructor(string memory name__, address hub_) {
        hub = hub_;
        name_ = name__;
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

    function getRouters()
        public view
        returns (address[] memory) {
        return IHub(hub).getRouters(address(this));
    }

    /// this is also useful for universal routers
    function name()
        public view
        returns (string memory) {
        return name_;
    }
}