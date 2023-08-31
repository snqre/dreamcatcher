// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/Storage.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv1-eternal-storage/Validator.sol";
import "contracts/polygon/templates/modular-upgradeable/hubv1-eternal-storage/Timelock.sol";

contract Launch {
    Storage storage_;
    Validator validator;
    Timelock timelock;
    constructor() {

        /**
        
            deploy storage
        
         */
        storage_ = new Storage();

        /**
        
            deploy validator, pass storage address

         */
        validator = new Validator({storage__: address(storage_)});

        /**
        
            deploy timelock, pass storage & validator address and settings
        
         */
        timelock = new Timelock({storage__: address(storage_), validator_: address(validator)});

        // add implementations
        storage_.addImplementation(address(validator));
        storage_.addImplementation(address(timelock));

        // init
        validator.init();
        timelock.init({enabledApproveAll: true, durationTimelock: 3600, durationTimeout: 7200});

        // grant timelock universal-key role
        validator.grantRole({account: address(timelock), role: "universal-key"});
        validator.grantRole({account: address(timelock), role: "validator"});

        // revoke all permissions
        validator.revokeRole({account: address(this), role: "validator"});
        storage_.removeAdmin({admin: address(this)});
    }
}