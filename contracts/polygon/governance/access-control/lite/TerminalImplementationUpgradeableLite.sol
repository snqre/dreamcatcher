// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/proxy/lite/DefaultImplementationLite.sol";
import "contracts/polygon/abstracts/access-control/lite/OwnableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/LowLevelCaller.sol";

/** Is the default owner of all contracts in the DAO can access all contracts. */
contract TerminalImplementationUpgradeableLite is DefaultImplementationLite, OwnableLite, LowLevelCaller {

    function initialize() public virtual {
        _initialize();
    }

    function upgrade(address newImplementation) public virtual {
        _onlyOwner();
        _upgrade(newImplementation);
    }

    function LowLevelCall(address target, bytes memory data) public virtual {
        _onlyOwner();
        _lowLevelCall(target, data);
    }

    function _initialize() internal virtual override {
        InitializableLite._initialize();
        OwnableLite._initialize(_msgSender());
    }
}