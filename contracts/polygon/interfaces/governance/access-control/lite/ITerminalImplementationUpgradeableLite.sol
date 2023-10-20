// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/proxy/lite/IDefaultImplementationLite.sol";
import "contracts/polygon/interfaces/abstracts/access-control/lite/IOwnableLite.sol";
import "contracts/polygon/interfaces/abstracts/proposal-toolkits/ILowLevelCaller.sol";

interface ITerminalImplementationUpgradeableLite is IDefaultImplementationLite, IOwnableLite, ILowLevelCaller {
    function initialize() external;

    function upgrade(address newImplementation) external;

    function lowLevelCall(address target, bytes memory data) external;
}