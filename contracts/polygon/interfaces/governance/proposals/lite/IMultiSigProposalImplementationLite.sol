// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/lite/IDefaultImplementationLite.sol";
import "contracts/polygon/interfaces/abstracts/access-control/lite/IOwnableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/IExecutableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/IPayloadLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ISettingsLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ISignableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ITagLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/lite/ITimerLite.sol";

interface IMultiSigProposalImplementationLite is IDefaultImplementationLite, IOwnableLite, IExecutableLite, IPayloadLite, ISettingsLite, ISignableLite, ITagLite, ITimerLite {

    function requiredSignaturesCount() external view returns (uint);

    function sufficientSignaturesCount() external view returns (uint);

    function sign() external;

    function initialize(string memory newName, string memory newNote, address newCreator, address[] memory signers, address newTarget, bytes memory newData, uint newRequiredQuorum, uint newStartTimestamp, uint newDuration) external;
}