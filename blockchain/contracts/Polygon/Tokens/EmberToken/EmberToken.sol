// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/** EMBER IS NOT MEANT TO BE BOUGHT OR TRADED IT IS USED AS A REPUTATION */

contract EmberToken is
ERC20,
ERC20Burnable,
ERC20Snapshot,
AccessControl,
ERC20Permit {
    constructor(
        address terminal
    ) ERC20(
        "EmberToken",
        "EMBER"
    ) ERC20Permit(
        "EmberToken"
    ) {
        /** grant default admin role to msg.sender */
        _grantRole(
            DEFAULT_ADMIN_ROLE, 
            msg.sender
        );

        /** grant default admin role to our terminal */
        _grantRole(
            DEFAULT_ADMIN_ROLE, 
            terminal
        );
    }

    /** non transferable */
    function _transfer() internal override {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
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

    function _mint(
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {
        super._mint(
            to,
            amount
        );
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {
        super._burn(
            account,
            amount
        );
    }

    function snapshot() public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {_snapshot();}

    function mint(
        address to,
        uint256 amount
    ) public onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
        _mint(
            to,
            amount
        );
    }

    function burn(
        address account,
        uint256 amount
    ) public override onlyRole(
        DEFAULT_ADMIN_ROLE
    ) {
        _burn(
            account,
            amount
        );
    }

    /** get total supply from the last snapshot */
    function getCurrentTotalSupply() public view returns (
        uint256
    ) {
        return totalSupplyAt(
            _getCurrentSnapshotId()
        );
    }

    /** note that weight is not in % but in basis points */
    function getWeight(
        address account
    ) public view returns (
        uint256
    ) {
        return (
            balanceOfAt(
                account,
                _getCurrentSnapshotId()
            ) / getCurrentTotalSupply()
        ) * 10000;
    }
    
    /** note that past weight is not in % in basis points */
    function getPastWeight(
        address account,
        uint256 snapshotId
    ) public view returns (
        uint256
    ) {
        require(
            snapshotId
            <= _getCurrentSnapshotId,
            "EmberToken::getPastWeight(): future lookup"
        );

        return (
            balanceOfAt(
                account,
                snapshotId
            ) / totalSupplyAt(
                snapshotId
            )
        ) * 10000;
    }
}