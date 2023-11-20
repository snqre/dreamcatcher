// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/interfaces/units/20/IToken.sol";
import "contracts/polygon/libraries/Command.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

library CommandCentre {
    using Command for Command.Command_;
    using EnumerableSet for EnumerableSet.AddressSet;
    /// context set externally
    enum Context {
        IS_IMPORTANT,
        IS_EMERGENCY,
        IS_NORMAL
    }

    struct CommandCentre_ {
        Context context;
        WrappedCommand[] commands;
        mapping(uint => address) commandsCreatorMapping;
        Operator[] operators;
        Settings settings;
    }
    /// wrapping command to add caption message and creator properties
    struct WrappedCommand {
        string caption;
        string message;
        address creator;
        Command.Command_ native;
    }

    struct Operator {
        address account;
        uint lastSignedInTimestamp;
    }

    struct Settings {
        address token;
        uint minBalanceToVote;
        uint requiredSignaturesInBasisPoints;
        uint requiredSupportInBasisPoints;
        uint multiSigDuration;
        uint referendumDuration;
        uint lockDuration;
        Command.Conduct conduct;
        /// duration until operator is signed out
        uint signInDuration;
        uint minRequiredActiveOperatorsInBasisPoints;
        bool paused;
        InactiveOperatorsTriggeredPayload inactiveOperatorsTriggeredPayload;
        
    }

    struct InactiveOperatorsTriggeredPayload {
        address target;
        bytes data;
    }

    function update(CommandCentre_ storage commandCentre) internal {
        if (!operatorsConditionsMet(commandCentre)) {
            /// not enough operators
            triggerCommandToSearchForNewOperators(commandCentre);
        }
    }

    function triggerCommandToSearchForNewOperators(CommandCentre_ storage commandCentre) internal {
        address[] memory targets;
        bytes[] memory data;
        targets[0] = commandCentre.settings.inactiveOperatorsTriggeredPayload.target;
        data[0] = commandCentre.settings.inactiveOperatorsTriggeredPayload.data;
        bytes memory emptyBytes;
        if (targets[0] != address(0) && keccak256(data[0]) != keccak256(emptyBytes)) {
            commandCentre.commands.push();
            WrappedCommand storage command = commandCentre.commands[commandCentre.commands.length - 1];
            command.caption = "InactiveOperatorsTriggeredPayload";
            command.message = "";
            command.creator = address(this);
            command.native.chooseConduct(Command.Conduct.MULTI_SIG);
            /// only active operators will become signers for this command
            address[] memory signers;
            for (uint i = 0; i < commandCentre.operators.length; i++) {
                /// operator is active
                if (block.timestamp < commandCentre.operators[i].lastSignedInTimestamp + commandCentre.settings.signInDuration) {
                    signers[i] = commandCentre.operators[i].account;
                }
            }
            command.native.setUpMultiSig(signers, commandCentre.settings.requiredSignaturesInBasisPoints, commandCentre.settings.multiSigDuration);
            command.native.setUpTimelock(commandCentre.settings.lockDuration);
            command.native.addPayload(targets[0], data[0]);
            command.native.enableRequireAllCallsSuccessful();
            command.native.forward();
        }
    }

    function sendCommand(CommandCentre_ storage commandCentre, address[] memory targets, bytes[] memory data, string memory caption, string memory message, address creator, bool requireAllCallsSuccessful) internal returns (uint) {
        require(targets.length == data.length, "Unable to set command because targets length do not match data length");
        commandCentre.commands.push();
        WrappedCommand storage command = commandCentre.commands[commandCentre.commands.length - 1];
        command.caption = caption;
        command.message = message;
        command.creator = creator;
        if (command.native.conductIsNotSet()) {
            command.native.chooseConduct(commandCentre.settings.conduct);
        }
        if (command.native.conductIsMultiSigOnly() || command.native.conductIsMultiSigFirstAndReferendumSecond() || command.native.conductIsReferendumFirstAndMultiSigSecond()) {
            /// operators are chosen signers
            address[] memory operators;
            for (uint i = 0; i < commandCentre.operators.length; i++) {
                operators[i] = commandCentre.operators[i].account;
            }
            command.native.setUpMultiSig(operators, commandCentre.settings.requiredSignaturesInBasisPoints, commandCentre.settings.multiSigDuration);
        }
        if (command.native.conductIsReferendumOnly() || command.native.conductIsMultiSigFirstAndReferendumSecond() || command.native.conductIsReferendumFirstAndMultiSigSecond()) {
            command.native.setUpReferendum(commandCentre.settings.token, commandCentre.settings.requiredSupportInBasisPoints, commandCentre.settings.referendumDuration);
        }
        command.native.setUpTimelock(commandCentre.settings.lockDuration);
        for (uint i = 0; i < targets.length; i++) {
            command.native.addPayload(targets[i], data[i]);
        }
        if (requireAllCallsSuccessful) {
            command.native.enableRequireAllCallsSuccessful();
        }
        /// begin command life cycle
        command.native.forward();
        return commandCentre.commands.length - 1;
    }

    function operatorsConditionsMet(CommandCentre_ storage commandCentre) internal view returns (bool) {
        (uint active, , uint numOperators) = checkOperatorsState(commandCentre);
        if (((active * 10000) / numOperators) >= commandCentre.settings.minRequiredActiveOperatorsInBasisPoints) {
            return true;
        }
        return false;
    }

    function checkOperatorsState(CommandCentre_ storage commandCentre) internal view returns (uint, uint, uint) {
        uint active;
        uint inactive;
        uint numOperators;
        for (uint i = 0; i < commandCentre.operators.length; i++) {
            if (block.timestamp >= commandCentre.operators[i].lastSignedInTimestamp + commandCentre.settings.signInDuration) {
                inactive ++;
            } else {
                active ++;
            }
            numOperators ++;
        }
        return (active, inactive, numOperators);
    }

    function contextIsImportant(CommandCentre_ storage commandCentre) internal view returns (bool) {
        return commandCentre.context == Context.IS_IMPORTANT;
    }

    function contextIsEmergency(CommandCentre_ storage commandCentre) internal view returns (bool) {
        return commandCentre.context == Context.IS_EMERGENCY;
    }

    function contextIsNormal(CommandCentre_ storage commandCentre) internal view returns (bool) {
        return commandCentre.context == Context.IS_NORMAL;
    }
}