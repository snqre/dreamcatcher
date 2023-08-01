// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/__Validator.sol";

contract Validator {
    address public storage_;
    constructor(address storage__) {
        storage_ = storage__;
    }

    function grantKey(address account, address of_, string memory signature, uint type_, uint startTimestamp, uint endTimestamp, uint balance)
        public {
        verify(msg.sender, address(this), "grantKey");
        __Validator.grantKey(storage_, account, of_, signature, type_, startTimestamp, endTimestamp, balance);
    }

    function revokeKey(address account, address of_, string memory signature)
        public {
        verify(msg.sender, address(this), "revokeKey");
        __Validator.revokeKey(storage_, account, of_, signature);
    }

    function verify(address account, address of_, string memory signature)
        public {
        __Validator.verify(storage_, account, of_, signature);
    }

    function getKeys(address account)
        public view
        returns (bytes32[] memory) {
        return __Validator.getKeys(storage_, account);
    }
}