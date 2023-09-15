// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";

contract Dream is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {

    /** @dev constructor */

    constructor() ERC20("Dream", "DREAM") ERC20Permit("Dream") {
        _mint(msg.sender, 200000000 * (10**18));
    }

    /** @dev external view */

    function getCurrentSnapshotId() external view returns (uint256) {
        return _getCurrentSnapshotId();
    }

    /** @dev external */

    function snapshot() external returns (uint256) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    /** @dev internal */
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
}