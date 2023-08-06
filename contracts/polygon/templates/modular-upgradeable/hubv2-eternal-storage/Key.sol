// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/Validator.sol";
import "contracts/polygon/deps/openzeppelin/security/ReentrancyGuard.sol";

contract Key is ReentrancyGuard {

    IStorage storage_;
    IValidator validator;

    constructor() {

        /**
        
            deploy storage, init

         */

        storage_ = IStorage(address(new Storage()));

        /**
        
            deploy validator, key now has validator role

         */
        
        validator = IValidator(address(new Validator(address(storage_))));

        // init implemenetations
        storage_.addImplementation(address(this));
        storage_.addImplementation(address(validator));

        // encode storage properties
        storage_.setBytes(_encode(".properties"), _encodeStorageProperties("M81, HUB000", "HUB", "DREAMCATCHER"));
    }

    function _encode(string memory string_)
        internal pure
        returns (bytes32) {
        return keccak256(abi.encode(string_));
    }

    function _encodeStorageProperties(string memory tag, string memory module, string memory class, string memory ecosystem)
        internal pure
        returns (bytes memory) {
        return abi.encode(tag, module, class, ecosystem);
    }

    function _decodeStorageProperties(bytes memory properties)
        internal pure
        returns (string memory, string memory, string memory, string memory) {
        (string memory tag, string memory module, string memory class, string memory ecosystem) = abi.decode(properties, (string, string, string));
        return (tag, module, class, ecosystem);
    }

    function _call(address target, string memory signature, bytes memory args)
        internal
        returns (bool, bytes memory) {
        (bool success, bytes memory response) = target.call(abi.encodeWithSignature(signature, args));
        return (success, response);
    }
}