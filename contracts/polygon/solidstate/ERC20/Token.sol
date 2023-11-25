// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Permit.sol";
import 'contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol';

interface IToken is IERC20, IERC20Metadata, IERC20Permit {
    function balanceOfAt(address account, uint snapshotId) external returns (uint);
    function totalSupplyAt(uint snapshotId) external returns (uint);
    
    function burn(uint amount) external;
    function burnFrom(address account, uint amount) external;

    function snapshot() external returns (uint);
}

contract Token is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    constructor(string memory name, string memory symbol, uint mint_) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, mint_ * (10**18));
    }

    function snapshot() external virtual returns (uint) {
        return _snapshot();
    }

    function _mint(address to, uint amount) internal virtual override {
        super._mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }   
}