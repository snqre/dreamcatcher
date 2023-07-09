// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/Key.sol";
import "contracts/polygon/projects/dreamcatcher/tokens/DreamToken.sol";
import "contracts/polygon/projects/dreamcatcher/finance/Vault.sol";
import "contracts/polygon/templates/libraries/Utils.sol";

contract Dreamcatcher is Key {
    DreamToken public dreamToken;
    Vault public vault;

    constructor() Key() {
        vault = new Vault(address(authenticator));

        /// on deployment will automatically send all suppy to vault.
        dreamToken = new DreamToken(address(vault));

        /// send team tokens to vesting wallets and a portion unlocked to team wallet.
        vault.transfer(address(dreamToken), 0x1e82a6E286fB5AD8d94ed843F4a66F96ec9862Da, Utils.convertToWei(10000000));
        
        createNewModule("dream-token", address(dreamToken), true, []);
        createNewModule("vault", address(vault), false, ["vault-transfer", "vault-transfer-from", "vault-withdraw"]);

        /// --------------------
        /// INITIAL ROLE SETTING.
        /// --------------------

        authenticator.createRole("chancellor", [], [], ["vault-transfer"], block.timestamp, 12 weeks);
        authenticator.grantRole(, caption, reset_);
    }
}