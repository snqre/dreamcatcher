// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    uint private _mintable;
    uint private _maxSupply;

    constructor() ERC20("DreamToken", "DREAM") ERC20Permit("DreamToken") Ownable() {
        _mintable = _convertToWei(200000000);
        _maxSupply = _convertToWei(200000000);

        _mint(
            _msgSender(),
            _convertToWei(200000000)
        );
    }

    function _convertToWei(uint value) private pure returns (uint) {
        return value * 10**18;
    }

    function _mustBeMintable(uint amount) private view {
        require(
            amount <= _mintable,
            "Insufficient mintable amount. The requested amount exceeds the available mintable tokens."
        );
    }

    function _mustNotBeFutureLookup(uint snapshot) private view {
        require(
            snapshot <= _getCurrentSnapshotId(),
            "Must not be future lookup."
        );
    }

    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint amount
    ) private override(
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
    ) private override {
        super._afterTokenTransfer(
            from,
            to,
            amount
        );
    }

    function _mint(
        address to,
        uint amount
    ) private override {
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
    ) private override {
        _maxSupply -= amount;
        super._burn(
            account,
            amount
        );
    }

    function snapshot_() external onlyOwner returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function mintable() external view returns (uint) { return _mintable; }
    function maxSupply() external view returns (uint) { return _maxSupply; }
    
    function getVotes(address account) external view returns (uint) {
        return balanceOfAt(
            account,
            _getCurrentSnapshotId()
        );
    }

    function getVotesAt(
        address account,
        uint snapshot
    ) external view returns (uint) {
        _mustNotBeFutureLookup(snapshot);
        return balanceOfAt(
            account,
            snapshot
        );
    }
}