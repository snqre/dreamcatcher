// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/libraries/Command.sol";
import "contracts/polygon/libraries/Utils.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

contract ConsoleFacetSlot01 {
    using Command for Command.Command_;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _CONSOLE01 = keccak256("slot.console.01");

    struct ConsoleFacetStorage01 {
        EnumerableSet.AddressSet operators;
        uint multiSigDuration;
        uint referendumDuration;
        uint lockDuration;
        address nativeToken;
        uint requiredSignaturesInBasisPoints;
        uint requiredSupportInBasisPoints;
        uint requiredBalanceToSendCommand;
        Command.Conduct conduct;
        Command.Command_[] commands;
        mapping(uint => address) identifierToCreatorMapping;
    }

    function console01() internal pure virtual returns (ConsoleFacetStorage01 storage s) {
        bytes32 location = _CONSOLE01;
        assembly {
            s.slot := location
        }
    }
}