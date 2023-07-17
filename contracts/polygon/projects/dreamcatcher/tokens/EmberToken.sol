// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable {
    constructor()
        ERC20("EmberToken", "EMBER")
        ERC20Permit("EmberToken") 
        Ownable(msg.sender) {

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

    function _transfer(address from, address to, uint amount)
        private override {
        revert("EmberToken: token transfer disabled by design");
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

    function mint(address to, uint amount)
        public 
        onlyOwner {
        _mint(to, amount);
    }

    function snapshot()
        public
        returns (uint) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function getCurrentSnapshotId()
        public view
        returns (uint) {
        return _getCurrentSnapshotId();
    }
}