// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/storage/Storage.sol";
import "contracts/polygon/abstract/utils/LowLevelCall.sol";
import "contracts/polygon/abstract/utils/Tag.sol";
import "contracts/polygon/abstract/utils/Timer.sol";
import "contracts/polygon/abstract/utils/Payload.sol";
import "contracts/polygon/abstract/access-control/Ownable.sol";
import "contracts/polygon/abstract/utils/Initializable.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";

abstract contract ReferendumProposal is 
    Storage,
    Tag,
    Payload,
    Timer,
    LowLevelCall,
    Initializable,
    Ownable {

    event SupportIncreased(address indexed account, uint256 indexed amount);

    event AgainstIncreased(address indexed account, uint256 indexed amount);

    event AbstainIncreased(address indexed account, uint256 indexed amount);

    event Passed();

    event Executed();

    event CaptionSet(string indexed caption);

    event MessageSet(string indexed message);

    event CreatorSet(address indexed creator);

    event TargetSet(address indexed target);

    event DataSet(address indexed data);

    event StartTimestampSet(uint256 indexed timestamp);

    event DurationSet(uint256 indexed seconds_);

    event RequiredQuorumSet(uint256 indexed bp);

    event RequiredThresholdSet(uint256 indexed bp);

    event SnapshotTaken(uint256 indexed id);

    event VotingERC20Set(address indexed erc20);

    function requiredQuorumKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_QUORUM"));
    }

    function requiredThresholdKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_THRESHOLD"));
    }

    function snapshotIdKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SNAPSHOT_ID"));
    }

    function votingERC20Key() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("VOTING_ERC20"));
    }

    function supportKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("SUPPORT"));
    }

    function againstKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("AGAINST"));
    }

    function abstainKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("ABSTAIN"));
    }

    function passedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("PASSED"));
    }

    function executedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("EXECUTED"));
    }

    function requiredQuorum() public view virtual returns (uint256) {
        return _uint256[requiredQuorumKey()];
    }

    function requiredThreshold() public view virtual returns (uint256) {
        return _uint256[requiredThresholdKey()];
    }

    function snapshotId() public view virtual returns (uint256) {
        return _uint256[snapshotIdKey()];
    }

    function votingERC20() public view virtual returns (address) {
        return _address[votingERC20Key()];
    }

    function support() public view virtual returns (uint256) {
        return _uint256[supportKey()];
    }

    function against() public view virtual returns (uint256) {
        return _uint256[againstKey()];
    }

    function abstain() public view virtual returns (uint256) {
        return _uint256[abstainKey()];
    }

    function quorum() public view virtual returns (uint256) {
        return support() + against() + abstain();
    }

    function requiredQuorumNumber() public view virtual returns (uint256) {
        IDream erc20 = IDream(votingERC20());
        uint256 totalSupplyAt = erc20.totalSupplyAt(snapshotId());
        return (totalSupplyAt * requiredQuorum()) / 10000;
    }

    function sufficientQuorum() public view virtual returns (bool) {
        return quorum() >= requiredQuorumNumber();
    }

    function threshold() public view virtual returns (uint256) {
        return (support() * 10000) / quorum();
    }

    function sufficientThreshold() public view virtual returns (bool) {
        return threshold() >= requiredThreshold();
    }

    function passed() public view virtual returns (bool) {
        return _bool[passedKey()];
    }

    function executed() public view virtual returns (bool) {
        return _bool[executedKey()];
    }

    function setRequiredQuorum(uint256 bp) public virtual {
        _onlyOwner();
        _setRequiredQuorum(bp);
    }

    function _vote(uint256 side) internal virtual {
        /** TODO */
        _update();
    }

    function _setRequiredQuorum(uint256 bp) internal virtual {
        require(bp <= 10000, "ReferendumProposal: out of bounds");
        _uint256[requiredQuorumKey()] = bp;
        emit RequiredQuorumSet(bp);
    }

    function _setRequiredThreshold(uint256 bp) internal virtual {
        require(bp <= 10000, "ReferendumProposal: out of bounds");
        _uint256[requiredThresholdKey()] = bp;
        emit RequiredThresholdSet(bp);
    }

    function _snapshot() internal virtual {
        _uint256[snapshotIdKey()] = IDream(votingERC20()).snapshot();
        emit SnapshotTaken(_uint256[snapshotidKey()]);
    }

    function _setVotingERC20(address erc20) internal virtual {
        _address[votingERC20()] = erc20;
        emit VotingERC20Set(erc20);
    }

    function _increaseSupport(uint256 amount) internal virtual {
        _uint256[supportKey()] += amount;
        emit SupportIncreased(msg.sender, amount);
    }

    function _increaseAgainst(uint256 amount) internal virtual {
        _uint256[againstKey()] += amount;
        emit AgainstIncreased(msg.sender, amount);
    }

    function _increaseAbstain(uint256 amount) internal virtual {
        _uint256[abstainKey()] += amount;
        emit AbstainIncreased(msg.sender, amount);
    }

    function _update() internal virtual {
        if (sufficientQuorum() && sufficientThreshold()) {
            _bool[passedKey()] = true;
            emit Passed();
        }
    }
}