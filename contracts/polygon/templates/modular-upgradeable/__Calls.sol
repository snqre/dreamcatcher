// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library __Calls {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// loop through contracts and attempt to use the signature and args
    /// if a call is successful it will break from the loop and return it as a successful call
    function call(address[] memory contracts, string memory signature, bytes memory args)
        public
        returns (bool, bytes memory, address) {
        bool success;
        bytes memory response;
        address contract_;
        for (uint i = 0; i < contracts.length; i++) {
            (success, response) = contracts[i].call(abi.encodeWithSignature(signature, args));
            if (success) { 
                contract_ = contracts[i];
                break; 
            }
        }
        return (success, response, contract_);
    }
}