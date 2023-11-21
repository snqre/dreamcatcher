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
        address admin;
        Context context;
        WrappedCommand[] commands;
        mapping(uint => address) commandsCreatorMapping; /// unused??
        Operator[] operators;
        Settings settings;
        bool switchedOn; /// unused spaghetti code
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
    /// in the future this method could be used to trigger commands such as elections
    struct InactiveOperatorsTriggeredPayload {
        uint lastTriggeredTimestamp;
        address target;
        bytes data;
    }

    /// checks and triggers
    function update(CommandCentre_ storage commandCentre) internal {
        if (!operatorsConditionsMet(commandCentre) && block.timestamp > commandCentre.settings.inactiveOperatorsTriggeredPayload.lastTriggeredTimestamp + commandCentre.settings.multiSigDuration + commandCentre.settings.lockDuration) {
            /// not enough operators
            commandCentre.settings.inactiveOperatorsTriggeredPayload.lastTriggeredTimestamp = block.timestamp;
            triggerCommandToSearchForNewOperators(commandCentre);
        }
    }

    function triggerCommandToSearchForNewOperators(CommandCentre_ storage commandCentre) internal {
        bytes memory emptyBytes;
        if (commandCentre.settings.inactiveOperatorsTriggeredPayload.target != address(0) && keccak256(commandCentre.settings.inactiveOperatorsTriggeredPayload.data) != keccak256(emptyBytes)) {
            commandCentre.commands.push();
            WrappedCommand storage command = commandCentre.commands[commandCentre.commands.length - 1];
            command.caption = "InactiveOperatorsTriggeredPayload";
            command.message = "";
            command.creator = address(this);
            command.native.chooseConduct(Command.Conduct.MULTI_SIG);
            /// only active operators will become signers for this command
            for (uint i = 0; i < commandCentre.operators.length; i++) {
                /// operator is active
                if (block.timestamp < commandCentre.operators[i].lastSignedInTimestamp + commandCentre.settings.signInDuration) {
                    command.native.addMultiSigSigner(commandCentre.operators[i].account);
                }
            }
            command.native.multiSig.requiredSignaturesInBasisPoints = commandCentre.settings.requiredSignaturesInBasisPoints;
            command.native.multiSig.timer.duration = commandCentre.settings.multiSigDuration;
            command.native.setUpTimelock(commandCentre.settings.lockDuration);
            command.native.addPayload(commandCentre.settings.inactiveOperatorsTriggeredPayload.target, commandCentre.settings.inactiveOperatorsTriggeredPayload.data);
            command.native.enableRequireAllCallsSuccessful();
            /// begin command lifecycle
            command.native.forward();
        }
    }

    function sendCommand(CommandCentre_ storage commandCentre, address[] memory targets, bytes[] memory data, string memory caption, string memory message, address creator, bool requireAllCallsSuccessful) internal returns (uint) {
        checkPaused(commandCentre);
        /// state machine checks
        update(commandCentre);
        require(targets.length == data.length, "Unable to send command because targets length do not match data length");
        commandCentre.commands.push();
        WrappedCommand storage command = commandCentre.commands[commandCentre.commands.length - 1];
        command.caption = caption;
        command.message = message;
        command.creator = creator;
        if (command.native.conductIsNotSet()) {
            command.native.chooseConduct(commandCentre.settings.conduct);
        }
        /// bypassing "setUpMultiSig" w custom method to add active signers
        if (command.native.conductIsMultiSigOnly() || command.native.conductIsMultiSigFirstAndReferendumSecond() || command.native.conductIsReferendumFirstAndMultiSigSecond()) {
            /// only active operators will become signers for this command
            for (uint i = 0; i < commandCentre.operators.length; i++) {
                /// operator is active
                if (block.timestamp < commandCentre.operators[i].lastSignedInTimestamp + commandCentre.settings.signInDuration) {
                    command.native.addMultiSigSigner(commandCentre.operators[i].account);
                }
            }
            command.native.multiSig.requiredSignaturesInBasisPoints = commandCentre.settings.requiredSignaturesInBasisPoints;
            command.native.multiSig.timer.duration = commandCentre.settings.multiSigDuration;
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

    /// unchecked with no multi sig or referendum
    function sendDirectCommand(CommandCentre_ storage commandCentre, address[] memory targets, bytes[] memory data, string memory caption, string memory message, address creator, bool requireAllCallsSuccessful) internal returns (uint) {
        /// state machine checks
        update(commandCentre);
        require(msg.sender == commandCentre.admin, "Unable to send direct command because you are not the admin");
        require(targets.length == data.length, "Unable to send command because targets length do not match data length");
        commandCentre.commands.push();
        WrappedCommand storage command = commandCentre.commands[commandCentre.commands.length - 1];
        command.caption = caption;
        command.message = message;
        command.creator = creator;
        command.native.chooseConduct(Command.Conduct.NONE);
        command.native.setUpTimelock(commandCentre.settings.lockDuration);
        for (uint i = 0; i < targets.length; i++) {
            command.native.addPayload(targets[i], data[i]);
        }
        if (requireAllCallsSuccessful) {
            command.native.enableRequireAllCallsSuccessful();
        }
        /// begin comand life cycle
        command.native.forward();
        return commandCentre.commands.length - 1;
    }

    /// progress the command
    function forwardCommand(CommandCentre_ storage commandCentre, uint identifier) internal {
        commandCentre.commands[identifier].native.forward();
    }

    function claimCommandCentre(CommandCentre_ storage commandCentre) internal {
        require(commandCentre.admin == address(0), "Unable to claim because admin role has already been claimed");
        commandCentre.admin = msg.sender;
    }

    function transferCommandCentreAdmin(CommandCentre_ storage commandCentre, address newAdmin) internal {
        require(commandCentre.admin == msg.sender, "Unable to transfer admin because you are not the admin");
        commandCentre.admin = newAdmin;
    }

    function signInAsOperator(CommandCentre_ storage commandCentre) internal {
        bool success;
        for (uint i = 0; i < commandCentre.operators.length; i++) {
            if (msg.sender == commandCentre.operators[i].account) {
                commandCentre.operators[i].lastSignedInTimestamp = block.timestamp;
                success = true;
            }
        }
        require(success, "Unable to sign in as operator because you are not an operator");
    }

    function setContext(CommandCentre_ storage commandCentre, Context newContext) internal {
        commandCentre.context = newContext;
    }

    function addOperator(CommandCentre_ storage commandCentre, address account) internal {
        require(account != address(0), "Unable to add operator because given address is zero");
        bool success;
        for (uint i = 0; i < commandCentre.operators.length; i++) {
            if (commandCentre.operators[i].account == address(0)) {
                commandCentre.operators[i].account = account;
                commandCentre.operators[i].lastSignedInTimestamp = block.timestamp;
                success = true;
            }
        }
        if (!success) {
            commandCentre.operators.push(Operator(account, block.timestamp));
            success = true;
        }
        require(success, "Unable to add operator because there may have been an error during execution");
    }

    function removeOperator(CommandCentre_ storage commandCentre, address account) internal {
        require(account != address(0), "Unable to remove operator because given address is zero");
        for (uint i = 0; i < commandCentre.operators.length; i++) {
            if (commandCentre.operators[i].account == account) {
                commandCentre.operators[i].account = address(0);
            }
        }
    }

    function isOperator(CommandCentre_ storage commandCentre, address account) internal view returns (bool) {
        for (uint i = 0; i < commandCentre.operators.length; i++) {
            if (commandCentre.operators[i].account == account) {
                return true;
            }
        }
        return false;
    }

    function setMultiSigDuration(CommandCentre_ storage commandCentre, uint newDuration) internal {
        require(newDuration != 0, "Unable to set multi sig duration because given value is zero");
        commandCentre.settings.multiSigDuration = newDuration;
    }

    function setReferendumDuration(CommandCentre_ storage commandCentre, uint newDuration) internal {
        require(newDuration != 0, "Unable to set referendum duration because given value is zero");
        commandCentre.settings.referendumDuration = newDuration;
    }

    function setTimelockDuration(CommandCentre_ storage commandCentre, uint newDuration) internal {
        require(newDuration != 0, "Unable to set timelock duration because given value is zero");
        commandCentre.settings.lockDuration = newDuration;
    }

    function setToken(CommandCentre_ storage commandCentre, address newToken) internal {
        require(newToken != address(0), "Unable to set token because given address is zero");
        require(newToken.code.length > 1, "Unable to set token because token is not a contract");
        commandCentre.settings.token = newToken;
    }

    function setRequiredSignaturesInBasisPoints(CommandCentre_ storage commandCentre, uint newValue) internal {
        require(newValue <= 10000, "Unable to set required signatures in basis points because value is greater than 10000");
        commandCentre.settings.requiredSignaturesInBasisPoints = newValue;
    }

    function setRequiredSupportInBasisPoints(CommandCentre_ storage commandCentre, uint newValue) internal {
        require(newValue <= 10000, "Unable to set required support in basis points because value is greater than 10000");
        commandCentre.settings.requiredSupportInBasisPoints = newValue;
    }

    function setMinBalanceToVote(CommandCentre_ storage commandCentre, uint newAmount) internal {
        commandCentre.settings.minBalanceToVote = newAmount;
    }

    function setConduct(CommandCentre_ storage commandCentre, Command.Conduct newConduct) internal {
        commandCentre.settings.conduct = newConduct;
    }

    function setSignInDuration(CommandCentre_ storage commandCentre, uint newDuration) internal {
        commandCentre.settings.signInDuration = newDuration;
    }

    function setMinRequiredActiveOperatorsInBasisPoints(CommandCentre_ storage commandCentre, uint newValue) internal {
        require(newValue <= 10000, "Unable to set min required active operators in basis points because value is greater than 10000");
        commandCentre.settings.minRequiredActiveOperatorsInBasisPoints = newValue;
    }

    function setInactiveOperatorsTriggeredPayload(CommandCentre_ storage commandCentre, address target, bytes memory data) internal {
        bytes memory emptyBytes;
        require(target != address(0) && keccak256(data) != keccak256(emptyBytes), "Unable to set inactive operators triggered payload because one or both given args are empty");
        commandCentre.settings.inactiveOperatorsTriggeredPayload = InactiveOperatorsTriggeredPayload(0, target, data);
    }

    function pause(CommandCentre_ storage commandCentre) internal {
        commandCentre.settings.paused = true;
    }

    function unpause(CommandCentre_ storage commandCentre) internal {
        commandCentre.settings.paused = false;
    }

    function checkPaused(CommandCentre_ storage commandCentre) internal view {
        require(commandCentre.settings.paused == false, "Unable to proceed because command centre is paused");
    }

    /// checks that there are enough active operators
    function operatorsConditionsMet(CommandCentre_ storage commandCentre) internal view returns (bool) {
        (uint active, , uint numOperators) = checkOperatorsState(commandCentre);
        /// **div by zero
        if (numOperators >= 2) {
            if (((active * 10000) / numOperators) >= commandCentre.settings.minRequiredActiveOperatorsInBasisPoints) {
                return true;
            }
        } else {
            /// if there ar eno more than two operators then will return true regardless
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