// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Timelock.sol";

contract Link is Timelock {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _terminals;
    mapping(address => EnumerableSet.AddressSet) private _routers;
    mapping(string => address) private _cache;

    function connect(string memory signature, bytes memory args)
        public
        returns (bytes memory) {
        bool success;
        bytes memory response;
        if (_cache[signature] != address(0)) {
            (success, response) = _cache[signature].call(abi.encodeWithSignature(signature, args));
            if (!success) { _cache[signature] = address(0); }
        }
        if (!success) {
            for (uint i = 0; i < _terminals.length(); i++) {
                for (uint x = 0; x < _routers[_terminals.at(i)].length(); x++) {
                    address target = _routers[_terminals.at(i)].at(x);
                    (success, response) = target.call(abi.encodeWithSignature(signature, args));
                    if (success) {
                        _cache[signature] = target;
                        break;
                    }
                }
                if (success) { break; }
            }
        }
        require(success, "Link: failed to find signature");
        return response;
    }
}