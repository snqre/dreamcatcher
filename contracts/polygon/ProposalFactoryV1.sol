// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/__Shared.sol";
import "contracts/polygon/ProxyStateOwnableContract.sol";
import "contracts/polygon/ProposalToUpgradeV1.sol";

contract ProposalFactoryV1 is ProxyStateOwnableContract {
    for EnumerableSet for EnumerableSet.AddressSet;

    function deployProposalToUpgradeV1() public {
        EnumerableSet.AddressSet storage proposals = _addressSet[keccak256(abi.encode("proposalToUpgradeV1s"))];
        proposals.add(new ProposalToUpgradeV1());

        _address[keccak256(abi.encode("proposalsToUpgradeV1", indexUnique))]
    }

    function _increment() internal returns (bool) {
        uint256 count = _uint256[keccak256(abi.encode("proposalsToUpgradeV1", "count"))]; count++;
        _uint256[keccak256(abi.encode("proposalsToUpgradeV1", "count"))] = count;
        return count;
    }
}