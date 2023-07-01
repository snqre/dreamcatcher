// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "smart_contracts/module_architecture/ModuleManager.sol";
import "smart_contracts/tokens/dream_token/DreamToken.sol";
import "smart_contracts/tokens/ember_token/EmberToken.sol";
import "smart_contracts/finance/vaults/vault/Vault.sol";
import "smart_contracts/module_architecture/Key.sol";
import "extensions/mirai/smart_contracts/polygon/mirai/Mirai.sol";

contract Dreamcatcher is Key {
    DreamToken private _dreamToken;
    EmberToken private _emberToken;
    Vault private _vault;
    Mirai private _mirai;

    constructor() Key("Dreamcatcher") {
        _vault = new Vault();
        _moduleManager.aquire("vault", address(_vault));

        _dreamToken = new DreamToken();
        _moduleManager.aquire("dream-token", address(_dreamToken));

        _dreamToken.transfer(address(_vault), _convertToWei(200000000));
        _vault.transfer(address(_dreamToken), 0x3945bBe12629671d1Dff6785758bdD6C18c28a83, _convertToWei(10000000));

        _emberToken = new EmberToken();
        _moduleManager.aquire("ember-token", address(_emberToken));

        _mirai = new Mirai(address(this));
        _moduleManager.aquire("mirai", address(_mirai));
    }

    /// helper function to convert normal numbers to wei.
    function _convertToWei(uint value) 
    internal virtual 
    returns (uint) {
        return value * 10**18;
    }
}