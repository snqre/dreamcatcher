// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";

import "smart_contracts/utils/Utils.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    constructor(address owner) ERC20("EmberToken", "EMBER") ERC20Permit("EmberToken") Ownable(owner) {}

    function _mustNotBeFutureLookup(uint snapshot) internal view {
        require(
            snapshot <= _getCurrentSnapshotId(),
            "EmberToken: Must not be future lookup."
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

        revert("EmberToken: Tokens are non-transferable by design.");
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

    function mint(
        address to,
        uint amount
    ) public onlyOwner {
        _mint(
            to,
            amount
        );
    }

    function mintByPoints(
        address to,
        uint points
    ) public onlyOwner {
        require(
            points >= 1 &&
            points <= 10000,
            "EmberToken: Points out of bounds"
        );

        uint amountToMint = (totalSupply() / 10000) * points;
        _mint(
            to,
            amountToMint
        );
    }

    function snapshot_() public onlyOwner returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function getWeight(address account) public view returns (uint) {
        uint balance = balanceOfAt(
            account,
            _getCurrentSnapshotId()
        );

        uint totalSupply = totalSupplyAt(_getCurrentSnapshotId());

        return (balance * 10000) / totalSupply;
    }

    function getPastWeight(
        address account,
        uint snapshot
    ) public view returns (uint) {
        _mustNotBeFutureLookup(snapshot);
        uint balance = balanceOfAt(
            account,
            snapshot
        );

        uint totalSupply = totalSupplyAt(_getCurrentSnapshotId());

        return (balance * 10000) / totalSupply;
    }
}