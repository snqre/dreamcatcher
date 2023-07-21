// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Timelock.sol";

contract Link is Timelock {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _terminals;

    mapping(address => bool) private _cache;
    
/**
    using EnumerableSet for EnumerableSet.AddressSet;
    
    EnumerableSet.AddressSet private _terminals;
    mapping(address => EnumerableSet.AddressSet) private _routers;

    /// cache mechanic if a call is made to an address and was previously successful then just go there immidietly
    /// what happens when there is a signature class? the first one found is picked but what about the second?
    /// can this be done any differently

    function connect(string memory signature, bytes memory args)
        public
        returns (bytes memory) {
        address target;
        bool success;
        bytes memory response;
        for (uint i = 0; i < _terminals.length(); i++) {
            for (uint x = 0; x < _routers[_terminals.at(i)].length(); x++) {
                target = _routers[_terminals.at(i)].at(x);
                (success, response) = target.call(abi.encodeWithSignature(signature, args));
                if (success) { break; }
            }
            if (success) { break; }
        }
        require(success, "Link: failed to find signature");
        return response;
    }
*/
}