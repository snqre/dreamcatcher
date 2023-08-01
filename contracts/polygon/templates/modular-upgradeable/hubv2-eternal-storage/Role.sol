// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/__Encoder.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/__Role.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv2-eternal-storage/Validator.sol";

contract Role is Validator {
    constructor(address storage__) 
        Validator(storage__) {
        
    }

    function grantKeyToRole(string memory role, address of_, string memory signature)
        public {
        __Role.grantKeyToRole(storage_, role, of_, signature);
    }

    function revokeKeyFromRole(string memory role, address of_, string memory signature)
        public {
        __Role.revokeKeyFromRole(storage_, role, of_, signature);
    }

    function grantRole(string memory role, address account)
        public {
        __Role.grantRole(storage_, role, account);
    }

    function revokeRole(string memory role, address account)
        public {
        __Role.revokeRole(storage_, role, account);
    }

    function getRoleMembers(string memory role)
        public view
        returns (address[] memory) {
        return __Role.getMembers(storage_, role);
    }

    function getRoleSize(string memory role)
        public view
        returns (uint) {
        return __Role.getSize(storage_, role);
    }
}