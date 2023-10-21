// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";

contract GovernanceToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, 200000000 * (10**18));
    }

    function getCurrentSnapshotId() external view returns (uint) {
        return _getCurrentSnapshotId();
    }

    function snapshot() external returns (uint256) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
}