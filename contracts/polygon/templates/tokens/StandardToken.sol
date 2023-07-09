// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/templates/libraries/Utils.sol";
import "contracts/polygon/templates/modular-upgradeable/Authenticator.sol";

contract StandardToken is ERC20, ERC20Burnable {
    IAuthenticator public authenticator;

    constructor(address addressAuthenticator) {
        authenticator = IAuthenticator(addressAuthenticator);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount)
        public
        returns (bool) {
        authenticator.authenticate(msg.sender, "standard-token-mint", true, true);
        _mint(to, amount);
        return true;
    }
}