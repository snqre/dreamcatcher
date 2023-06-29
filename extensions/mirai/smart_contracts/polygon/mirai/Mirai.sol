// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
import "deps/openzeppelin/access/Ownable.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";
import "smart_contracts/module_architecture/Key.sol";
import "extensions/mirai/smart_contracts/polygon/factory/Factory.sol";

contract Mirai is Key {
    IKey private _dreamcatcher;
    IERC20 private _dreamToken;
    IERC20 private _emberToken;

    constructor(
        address dreamcatcher,
        address dreamToken,
        address emberToken
    ) Key("Mirai") {
        _moduleManager.grantGovernance("dreamcatcher");
        _dreamcatcher = IKey(dreamcatcher);
        _dreamToken = IERC20(dreamToken);
        _emberToken = IERC20(emberToken);
    }

    function getAddressOfDreamcatcher()
    public view
    returns (address) {
        return address(_dreamcatcher);
    }

    function getAddressOfDreamToken()
    public view
    returns (address) {
        return address(_dreamToken);
    }

    function getAddressOfEmberToken()
    public view
    returns (address) {
        return address(_emberToken);
    }
}