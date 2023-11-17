// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/interfaces/tokens/erc20/IGovernanceToken.sol";

/** Required quorum and threshold are in basis points */
abstract contract SettingsLite is StorageLite {
    
    event RequiredQuorumUpdated(uint indexed previousRequiredQuorum, uint indexed newRequiredQuorum);

    event RequiredThresholdUpdated(uint indexed previousRequiredThreshold, uint indexed newRequiredThreshold);

    event GovernanceTokenUpdated(address indexed previousToken, address indexed newToken);

    event Snapped(uint indexed newSnapshotId);

    function requiredQuorum() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____requiredQuorum()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____requiredQuorum()], (uint));
    }

    function requiredThreshold() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____requiredThreshold()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____requiredThreshold()], (uint));
    }

    function governanceToken() public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____governanceToken()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____governanceToken()], (address));
    }

    function snapshotId() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____snapshotId()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____snapshotId()], (uint));
    }

    function ____requiredQuorum() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_QUORUM"));
    }

    function ____requiredThreshold() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("REQUIRED_THRESHOLD"));
    }

    function ____governanceToken() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("GOVERNANCE_TOKEN"));
    }

    function ____snapshotId() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("SNAPSHOT_ID"));
    }

    function _setRequiredQuorum(uint newRequiredQuorum) internal virtual {
        require(newRequiredQuorum <= 10000, "SettingsLite: out of bounds | > 10000");
        uint previousRequiredQuorum = requiredQuorum();
        _bytes[____requiredQuorum()] = abi.encode(newRequiredQuorum);
        emit RequiredQuorumUpdated(previousRequiredQuorum, newRequiredQuorum);
    }

    function _setRequiredThreshold(uint newRequiredThreshold) internal virtual {
        require(newRequiredThreshold <= 10000, "SettingsLite: out of bounds | > 10000");
        uint previousRequiredThreshold = requiredThreshold();
        _bytes[____requiredThreshold()] = abi.encode(newRequiredThreshold);
        emit RequiredThresholdUpdated(previousRequiredThreshold, newRequiredThreshold);
    }

    function _setGovernanceToken(address newToken) internal virtual {
        address previousToken = governanceToken();
        _bytes[____governanceToken()] = abi.encode(newToken);
        emit GovernanceTokenUpdated(previousToken, newToken);
    }

    function _snapshot() internal virtual {
        IGovernanceToken governanceToken = IGovernanceToken(governanceToken());
        uint newSnapshotId = governanceToken.snapshot();
        _bytes[____snapshotId()] = abi.encode(newSnapshotId);
        emit Snapped(newSnapshotId);
    }
}