// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/proxy/lite/DefaultImplementationLite.sol";
import "contracts/polygon/abstracts/access-control/lite/OwnableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/ExecutableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/PayloadLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/SettingsLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/VotableLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/TagLite.sol";
import "contracts/polygon/abstracts/proposal-toolkits/lite/TimerLite.sol";
import "contracts/polygon/interfaces/tokens/erc20/IGovernanceToken.sol";

contract ReferendumProposalImplementationLite is DefaultImplementationLite, OwnableLite, ExecutableLite, PayloadLite, SettingsLite, VotableLite, TagLite, TimerLite {

    function requiredQuorumCount() public view virtual returns (uint) {
        IGovernanceToken governanceToken = IGovernanceToken(governanceToken());
        uint totalSupplyAt = governanceToken.totalSupplyAt(snapshotId());
        return (totalSupplyAt * requiredQuorum()) / 10000;
    }
    
    function sufficientQuorumCount() public view virtual returns (bool) {
        return quorum() >= requiredQuorumCount();
    }

    function sufficientThreshold() public view virtual returns (bool) {
        return threshold() >= requiredThreshold();
    }

    function vote(uint side) public virtual {
        _vote(side);
    }

    function _initialize(string memory newName, string memory newNote, address newCreator, address newTarget, bytes memory newData, uint newRequiredQuorum, uint newRequiredThreshold, address newGovernanceToken, uint newStartTimestamp, uint newDuration) internal virtual override {
        InitializableLite._initialize();
        OwnableLite._initialize(_msgSender());
        _snapshot();
        _setName(newName);
        _setNote(newNote);
        _setCreator(newCreator);
        _setTarget(newTarget);
        _setData(newData);
        _setRequiredQuorum(newRequiredQuorum);
        _setRequiredThreshold(newRequiredThreshold);
        _setGovernanceToken(newGovernanceToken);
        _setStartTimestamp(newStartTimestamp);
        _setDuration(newDuration);
    }

    function _vote(uint8 side) internal virtual override {
        VotableLite._vote(side, governanceToken(), snapshotId());
        if (!approved() && !executed()) {
            if (sufficientQuorumCount() && sufficientThreshold()) {
                _approve();
                _execute();
            }
        }
    }

}