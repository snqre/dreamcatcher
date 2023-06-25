// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    constructor() ERC20("EmberToken", "EMBER") ERC20Permit("EmberToken") Ownable() {}

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

        revert("Tokens are non-transferable by design.");
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

    function mint(
        address to,
        uint amount
    ) external onlyOwner {
        _mint(
            to,
            amount
        );
    }

    function mintUsingBasisPoints(
        address to,
        uint points
    ) external onlyOwner {
        require(
            points >= 1 &&
            points <= 10000,
            "Points out of bounds."
        );

        uint amountToMint = (totalSupply() / 10000) * points;
        _mint(
            to,
            amountToMint
        );
    }

    function snapshot_() external onlyOwner returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function getWeight(address account) external view returns (uint) {
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
    ) external view returns (uint) {
        _mustNotBeFutureLookup(snapshot);
        uint balance = balanceOfAt(
            account,
            snapshot
        );

        uint totalSupply = totalSupplyAt(_getCurrentSnapshotId());

        return (balance * 10000) / totalSupply;
    }
}