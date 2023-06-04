// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

/** once these are loaded locally reset imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "blockchain/contracts/Polygon/Tokens/EmberToken/EmberToken.sol";
import "smart_contracts\utils\Utils.sol";
 */

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    uint mintable_;
    
    EmberToken emberToken;

    constructor(address terminal) ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") {
        if (msg.sender == terminal) {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }

        else {
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal);
        }
        
        mintable_ = Utils.convertToWei(200000000);

        _mint(terminal, Utils.convertToWei(180000000));

        emberToken = new EmberToken(terminal);
    }

    // required override
    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint amount) internal override {
        require(mintable_ <= amount, "mintable_ > amount");

        mintable_ -= amount;

        super._mint(to, amount);
    }

    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function mintable() public view returns (uint) {
        return mintable_;
    }

    function getVotes(address account) public view returns (uint) {
        uint baseVotes = balanceOfAt(account, _getCurrentSnapshotId());
        uint weight = emberToken.getWeight(account);
        uint additionalVotes = (baseVotes * weight) / 10000;

        return baseVotes + additionalVotes;
    }

    function getPastVotes(address account, uint snapshotId) public view returns (uint) {
        uint baseVotes = balanceOfAt(account, snapshotId);
        uint weight = emberToken.getPastWeight(account, snapshotId);
        uint additionalVotes = (baseVotes * weight) / 10000;

        return baseVotes + additionalVotes;
    }
}