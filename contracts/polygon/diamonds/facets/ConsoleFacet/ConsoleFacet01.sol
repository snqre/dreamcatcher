// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/libraries/Command.sol";
import "contracts/polygon/libraries/CommandCentre.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/units/20/IToken.sol";

contract ConsoleFacet01 {
    using Command for Command.Command_;
    using CommandCentre for CommandCentre.CommandCentre_;
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _CONSOLE_01 = keccak256("slot.console.01");

    enum Phase {
        NONE,
        MULTI_SIG,
        REFERENDUM,
        TIMELOCK,
        COMPLETE,
        FAILED
    }

    struct ConsoleFacetStorage01 {
        CommandCentre.CommandCentre_ commandCentre;
    }

    event CommandReceived(uint identifier);
    event AdminChanged(address oldAdmin, address newAdmin);
    event CommandForwarded(uint identifier);

    function console01() internal pure virtual returns (ConsoleFacetStorage01 storage s) {
        bytes32 location = _CONSOLE_01;
        assembly {
            s.slot := location
        }
    }

    function getCommandSummary(uint identifier) public view virtual returns (string memory caption, string memory message, address creator, Command.Conduct conduct, Phase phase) {
        caption = console01().commandCentre.commands[identifier].caption;
        message = console01().commandCentre.commands[identifier].message;
        creator = console01().commandCentre.commands[identifier].creator;
        conduct = console01().commandCentre.commands[identifier].native.conduct;
        if (console01().commandCentre.commands[identifier].native.phaseIsNone()) {
            phase = Phase.NONE;
        } else if (console01().commandCentre.commands[identifier].native.phaseIsMultiSig()) {
            phase = Phase.MULTI_SIG;
            /// if the time is out and conditions have not been met then it has failed
            if (!console01().commandCentre.commands[identifier].native.multiSigConditionsMet() && block.timestamp >= console01().commandCentre.commands[identifier].native.multiSig.timer.startTimestamp + console01().commandCentre.commands[identifier].native.multiSig.timer.duration) {
                phase = Phase.FAILED;
            }
        } else if (console01().commandCentre.commands[identifier].native.phaseIsReferendum()) {
            phase = Phase.REFERENDUM;
            /// if the time is out and conditions have not been met then it has failed
            if (!console01().commandCentre.commands[identifier].native.referendumConditionsMet() && block.timestamp >= console01().commandCentre.commands[identifier].native.referendum.timer.startTimestamp + console01().commandCentre.commands[identifier].native.referendum.timer.duration) {
                phase = Phase.FAILED;
            }
        } else if (console01().commandCentre.commands[identifier].native.phaseIsTimelock()) {
            phase = Phase.TIMELOCK;
            /// if the time is out and conditions have not been met then it has failed
            if (!console01().commandCentre.commands[identifier].native.timelockConditionsMet() && block.timestamp >= console01().commandCentre.commands[identifier].native.lock.timer.startTimestamp + console01().commandCentre.commands[identifier].native.lock.timer.duration) {
                phase = Phase.FAILED;
            }
        } else if (console01().commandCentre.commands[identifier].native.lifeCycleIsComplete()) {
            phase = Phase.COMPLETE;
        }
        return (caption, message, creator, conduct, phase);
    }

    function getCommandPayload(uint identifier, uint payloadId) public view virtual returns (address target, bytes memory data) {
        return (console01().commandCentre.commands[identifier].native.payloads[payloadId].target, console01().commandCentre.commands[identifier].native.payloads[payloadId].data);
    }

    /// to be used immidietly after deployment
    function claimCommandCentre() public virtual {
        /// grants the first caller admin permission
        console01().commandCentre.claimCommandCentre();
        emit AdminChanged(address(0), msg.sender);
    }

    function transferCommandCentreAdmin(address newAdmin) public virtual {
        console01().commandCentre.transferCommandCentreAdmin(newAdmin);
        /// only admin can call this function
        emit AdminChanged(msg.sender, newAdmin);
    }

    function sendCommand(address[] memory targets, bytes[] memory data, string memory caption, string memory message, bool requireAllCallsSuccessful) public virtual returns (uint) {
        bool isOperator = console01().commandCentre.isOperator(msg.sender);
        if (!isOperator) {
            if (msg.sender == console01().commandCentre.admin) {
                uint identifier = console01().commandCentre.sendDirectCommand(targets, data, caption, message, msg.sender, requireAllCallsSuccessful);
                emit CommandReceived(identifier);
                return identifier;
            }
            IToken token = IToken(console01().commandCentre.settings.token);
            require(token.balanceOf(msg.sender) >= console01().commandCentre.settings.minBalanceToVote, "Unable to send command because you have insufficient balance");
        } else {
            /// sending a command counts as being an active operator
            console01().commandCentre.signInAsOperator();
        }
        uint identifier = console01().commandCentre.sendCommand(targets, data, caption, message, msg.sender, requireAllCallsSuccessful);
        emit CommandReceived(identifier);
        return identifier;
    }

    /// when command is polling it should be forwarded to the next stages through its life cycle
    function forwardCommand(uint identifier) public virtual {
        bool isOperator = console01().commandCentre.isOperator(msg.sender);
        if (isOperator) {
            /// forwarding a command counts as being an active operator
            console01().commandCentre.signInAsOperator();
        }
        console01().commandCentre.forwardCommand(identifier);
        emit CommandForwarded(identifier);
    }

    function signInAsOperator() public virtual {
        /// sign it to retain active state
        console01().commandCentre.signInAsOperator();
    }
}