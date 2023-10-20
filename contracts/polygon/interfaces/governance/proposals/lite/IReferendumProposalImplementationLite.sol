// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/lite/IDefaultImplementationLite.sol";
import "contracts/polygon/interfaces/abstracts/access-control/lite/IOwnableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/IExecutableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/IPayloadLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ISettingsLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/IVotableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ITagLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ITimerLite.sol";

interface IReferendumProposalImplementationLite is IDefaultImplementationLite, IOwnableLite, IExecutableLite, IPayloadLite, ISettingsLite, IVotable, ITagLite, ITimerLite {

    function requiredQuorumCount() external view returns (uint);

    function sufficientQuorumCount() external view returns (bool);

    function sufficientThreshold() external view returns (bool);

    function vote(uint side) external;
}