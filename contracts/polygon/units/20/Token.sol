// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import 'contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Permit.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Permit.sol';
import 'contracts/polygon/deps/openzeppelin/access/Ownable.sol';

contract Token is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    constructor(string memory name, string memory symbol, uint initSupply) ERC20(name, symbol) ERC20Permit(name) Ownable(msg.sender) {
        _mint(msg.sender, initSupply * (10**18));
    }

    function getCurrentSnapshotId() external view virtual returns (uint) {
        return _getCurrentSnapshotId();
    }

    function mint(address account, uint amount) external virtual onlyOwner {
        _mint(account, amount);
    }

    function snapshot() external virtual returns (uint) {
        return _snapshot();
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
}