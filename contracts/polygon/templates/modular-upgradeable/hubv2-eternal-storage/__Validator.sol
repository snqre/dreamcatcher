// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/__Encoder.sol";
import "contracts/polygon/templates/____Storage.sol";

library __Validator {
    function grantKey(address storage__, address account, address of_, string memory signature)
        public {
        ____IStorage storage_ = ____IStorage(storage__);
        storage_.addBytes32SetStorage(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature));
    }

    function revokeKey(address storage__, address account, address of_, string memory signature)
        public {
        ____IStorage storage_ = ____IStorage(storage__);
        storage_.removeAddressSetStorage(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature));
    }

    function verify(address storage__, address account, address of_, string memory signature)
        public view {
        ____IStorage storage_ = ____IStorage(storage__);
        bool hasKey = storage_.containsAddressSetStorage(__Encoder.encodeWithAccount("keys", account), __Encoder.encodeKey(of_, signature));
        require(hasKey, "__Validator: account does not have required key");
    }
}