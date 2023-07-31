// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/__Validator.sol";

contract Validator {
    address storage_;
    constructor(address storage__) {
        storage_ = storage__;
    }

    function grantKey(address account, address of_, string memory signature)
        public {
        __Validator.grantKey(storage_, account, of_, signature);
    }

    function revokeKey(address account, address of_, string memory signature)
        public {
        __Validator.revokeKey(storage_, account, of_, signature);
    }

    function verify(address account, address of_, string memory signature)
        public view {
        __Validator.verify(storage_, account, of_, signature);
    }
}