// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/interfaces/tokens/erc20/IGovernanceToken.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract VotableLite is StorageLite, Context {

    event VoteCasted(address indexed voter, uint8 indexed side, uint indexed amount);

    function support() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____support()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____support()], (uint));
    }

    function against() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____against()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____against()], (uint));
    }

    function abstain() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____abstain()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____abstain()], (uint));
    }

    function quorum() public view virtual returns (uint) {
        return support() + against() + abstain();
    }

    function threshold() public view virtual returns (uint) {
        return (support() * 10000) / quorum();
    }

    function ____support() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("SUPPORT"));
    }

    function ____against() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("AGAINST"));
    }

    function ____abstain() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("ABSTAIN"));
    }

    function _vote(uint8 side, address governanceToken, uint snapshotId) internal virtual {
        uint balanceOfAt = IGovernanceToken(governanceToken).balanceOfAt(_msgSender(), snapshotId);
        if (side == 0) {
            _raiseVote(____abstain(), balanceOfAt);
        } else if (side == 1) {
            _raiseVote(____against(), balanceOfAt);
        } else if (side == 2) {
            _raiseVote(____abstain(), balanceOfAt);
        } else {
            revert ("VotableLite: unrecognized side");
        }
        emit VoteCasted(_msgSender(), side, balanceOfAt);
    }

    function _raiseVote(bytes32 side, uint amount) internal virtual {
        uint count = abi.decode(_bytes[side], (uint));
        count += amount;
        _bytes[side] = abi.encode(count);
    }
}