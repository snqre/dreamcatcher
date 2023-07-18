// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    uint public cap;

    constructor()
        ERC20("DreamToken", "DREAM")
        ERC20Permit("DreamToken") {
        cap = _convertToWei(200000000);
        _mint(msg.sender, _convertToWei(200000000));
    }

    function _convertToWei(uint value)
        private pure
        returns (uint) {
        return value * (10**18);
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
        private override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint amount)
        private override {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint amount)
        private override {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal override {
        cap -= amount;
        super._burn(account, amount);
    }

    function maxSupply() 
        public view 
        returns (uint) { 
        return cap; 
    }

    function snapshot()
        external
        returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function getCurrentSnapshotId()
        external view
        returns (uint) {
        return _getCurrentSnapshotId();
    }
}