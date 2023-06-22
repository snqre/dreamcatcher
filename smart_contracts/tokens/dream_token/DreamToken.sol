// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";

import "smart_contracts/utils/Utils.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    uint private _mintable;
    uint private _maxSupply;

    constructor(address owner) ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") Ownable(owner) {
        _mintable = Utils.convertToWei(200000000);
        _maxSupply = Utils.convertToWei(200000000);
        _mint(
            owner,
            Utils.convertToWei(200000000)
        );
    }

    function _mustBeMintable(uint amount) internal view {
        require(
            amount <= _mintable,
            "DreamToken: Insufficient mintable amount. The requested amount exceeds the available mintable tokens."
        );
    }

    function _mustNotBeFutureLookup(uint snapshot) internal view {
        require(
            snapshot <= _getCurrentSnapshotId(),
            "DreamToken: Must not be future lookup."
        );
    }

    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint amount
    ) internal override(
        ERC20, 
        ERC20Snapshot
    ) {
        super._beforeTokenTransfer(
            from, 
            to, 
            amount
        );
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal override {
        super._afterTokenTransfer(
            from,
            to,
            amount
        );
    }

    function _mint(
        address to,
        uint amount
    ) internal override {
        _mustBeMintable(amount);
        _mintable -= amount;
        super._mint(
            to,
            amount
        );
    }

    function _burn(
        address account,
        uint amount
    ) internal override {
        _maxSupply -= amount;
        super._burn(
            account,
            amount
        );
    }

    function snapshot_() public onlyOwner returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function mintable() public view returns (uint) { return _mintable; }
    function maxSupply() public view returns (uint) { return _maxSupply; }
    
    function getVotes(address account) public view returns (uint) {
        return balanceOfAt(
            account,
            _getCurrentSnapshotId()
        );
    }

    function getVotesAt(
        address account,
        uint snapshot
    ) public view returns (uint) {
        _mustNotBeFutureLookup(snapshot);
        return balanceOfAt(
            account,
            snapshot
        );
    }
}