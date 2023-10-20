// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/proxy/lite/DefaultImplementationLite.sol";
import "contracts/polygon/abstracts/access-control/lite/OwnableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/ExecutableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/PayloadLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/SettingsLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/SignableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/TagLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/TimerLite.sol";

/**
* The proposals are not intended to be upgradeable to preserve immutability during
* the voting process.
 */
contract MultiSigProposalImplementationLite is DefaultImplementationLite, OwnableLite, ExecutableLite, PayloadLite, SettingsLite, SignableLite, TagLite, TimerLite {

    function requiredSignaturesCount() public view virtual returns (uint) {
        return (signaturesCount() * requiredQuorum()) / 10000;
    }

    function sufficientSignaturesCount() public view virtual returns (uint) {
        return signaturesCount() >= requiredSignaturesCount();
    }

    function sign() public virtual {
        _sign();
    }

    function initialize(string memory newName, string memory newNote, address newCreator, address[] memory signers, address newTarget, bytes memory newData, uint newRequiredQuorum, uint newStartTimestamp, uint newDuration) public virtual {
        _initialize(newName, newNote, newCreator, signers, newTarget, newData, newRequiredQuorum, newStartTimestamp, newDuration);
    }

    function _initialize(string memory newName, string memory newNote, address newCreator, address[] memory signers, address newTarget, bytes memory newData, uint newRequiredQuorum, uint newStartTimestamp, uint newDuration) internal virtual override {
        InitializableLite._initialize();
        OwnableLite._initialize(_msgSender());
        _setName(newName);
        _setNote(newNote);
        _setCreator(newCreator);
        for (uint i = 0; i < signers.length; i++) {
            _addSigner(signers[i]);
        }
        _setTarget(newTarget);
        _setData(newData);
        _setRequiredQuorum(newRequiredQuorum);
        _setStartTimestamp(newStartTimestamp);
        _setDuration(newDuration);
    }

    function _sign() internal virtual override {
        super._sign();
        if (!approved() && !executed()) {
            if (sufficientSignaturesCount()) {
                _approve();
                _execute();
            }
        }
    }
}