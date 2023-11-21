// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/libraries/Command.sol";
import "contracts/polygon/libraries/CommandCentre.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/units/20/IToken.sol";

/// enabled the diamond to make target calls based on a polled command
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
    event TokenChanged(address oldToken, address newToken);
    event MinBalanceToVoteChanged(uint oldValue, uint newValue);
    event RequiredSignaturesInBasisPointsChanged(uint oldValue, uint newValue);
    event RequiredSupportInBasisPointsChanged(uint oldValue, uint newValue);
    event MultiSigDurationChanged(uint oldDuration, uint newDuration);
    event ReferendumDurationChanged(uint oldDuration, uint newDuration);
    event TimelockDurationChanged(uint oldDuration, uint newDuration);
    event SignInDurationChanged(uint oldDuration, uint newDuration);
    event MinRequiredActiveOperatorsInBasisPointsChanged(uint oldValue, uint newValue);

    function console01() internal pure virtual returns (ConsoleFacetStorage01 storage s) {
        bytes32 location = _CONSOLE_01;
        assembly {
            s.slot := location
        }
    }

    function ____setToken(address newToken) external virtual {
        _onlySelf();
        address oldToken = console01().commandCentre.settings.token;
        console01().commandCentre.settings.token = newToken;
        emit TokenChanged(oldToken, newToken);
    }

    function ____setMinBalanceToVote(uint newValue) external virtual {
        _onlySelf();
        uint oldValue = console01().commandCentre.settings.minBalanceToVote;
        console01().commandCentre.settings.minBalanceToVote = newValue;
        emit MinBalanceToVoteChanged(oldValue, newValue);
    }

    function ____setRequiredSignaturesInBasisPoints(uint newValue) external virtual {
        _onlySelf();
        _checkBasisPoints(newValue);
        uint oldValue = console01().commandCentre.settings.requiredSignaturesInBasisPoints;
        console01().commandCentre.settings.requiredSignaturesInBasisPoints = newValue;
        emit RequiredSignaturesInBasisPointsChanged(oldValue, newValue);
    }

    function ____setRequiredSupportInBasisPoints(uint newValue) external virtual {
        _onlySelf();
        _checkBasisPoints(newValue);
        uint oldValue = console01().commandCentre.settings.requiredSupportInBasisPoints;
        emit RequiredSupportInBasisPointsChanged(oldValue, newValue);
    }

    function ____setMultiSigDuration(uint newDuration) external virtual {
        _onlySelf();
        uint oldDuration = console01().commandCentre.settings.multiSigDuration;
        console01().commandCentre.settings.multiSigDuration = newDuration;
        emit MultiSigDurationChanged(oldDuration, newDuration);
    }

    function ____setReferendumDuration(uint newDuration) external virtual {
        _onlySelf();
        uint oldDuration = console01().commandCentre.settings.referendumDuration;
        console01().commandCentre.settings.referendumDuration = newDuration;
        emit ReferendumDurationChanged(oldDuration, newDuration);
    }

    function ____setTimelockDuration(uint newDuration) external virtual {
        _onlySelf();
        uint oldDuration = console01().commandCentre.settings.lockDuration;
        console01().commandCentre.settings.lockDuration = newDuration;
        emit TimelockDurationChanged(oldDuration, newDuration);
    }

    function ____setSignInDuration(uint newDuration) external virtual {
        _onlySelf();
        uint oldDuration = console01().commandCentre.settings.signInDuration;
        console01().commandCentre.settings.signInDuration = newDuration;
        emit SignInDurationChanged(oldDuration, newDuration);
    }

    function ____setMinRequiredActiveOperatorsInBasisPoints(uint newValue) external virtual {
        _onlySelf();
        _checkBasisPoints(newValue);
        uint oldValue = console01().commandCentre.settings.minRequiredActiveOperatorsInBasisPoints;
        console01().commandCentre.settings.minRequiredActiveOperatorsInBasisPoints = newValue;
        emit MinRequiredActiveOperatorsInBasisPointsChanged(oldValue, newValue);
    }

    function _onlySelf() internal view virtual {
        require(msg.sender == address(this), "Unable to proceed because you are not the contract");
    }

    function _checkBasisPoints(uint value) internal view virtual {
        require(value <= 10000, "Unable to proceed because value in basis points but given value is greater than 10000");
    }

    function getAdmin() public view virtual returns (address) {
        return console01().commandCentre.admin;
    }

    function getContext() public view virtual returns (CommandCentre.Context) {
        return console01().commandCentre.context;
    }

    function getOperators(uint operatorId) public view virtual returns (address) {
        return console01().commandCentre.operators[operatorId].account;
    }

    function getOperatorsLastSignedInTimestamp(uint operatorId) public view virtual returns (uint) {
        return console01().commandCentre.operators[operatorId].lastSignedInTimestamp;
    }

    function getCommandCentreSettings() public view virtual returns (address token, uint minBalanceToVote, uint requiredSignaturesInBasisPoints, uint requiredSupportInBasisPoints, uint multiSigDuration, uint referendumDuration, uint lockDuration, uint signInDuration, uint minRequiredActiveOperatorsInBasisPoints) {
        token = console01().commandCentre.settings.token;
        minBalanceToVote = console01().commandCentre.settings.minBalanceToVote;
        requiredSignaturesInBasisPoints = console01().commandCentre.settings.requiredSignaturesInBasisPoints;
        requiredSupportInBasisPoints = console01().commandCentre.settings.requiredSupportInBasisPoints;
        multiSigDuration = console01().commandCentre.settings.multiSigDuration;
        referendumDuration = console01().commandCentre.settings.referendumDuration;
        lockDuration = console01().commandCentre.settings.lockDuration;
        signInDuration = console01().commandCentre.settings.signInDuration;
        minRequiredActiveOperatorsInBasisPoints = console01().commandCentre.settings.minRequiredActiveOperatorsInBasisPoints;
        return (token, minBalanceToVote, requiredSignaturesInBasisPoints, requiredSupportInBasisPoints, multiSigDuration, referendumDuration, lockDuration, signInDuration, minRequiredActiveOperatorsInBasisPoints);
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
        console01().commandCentre.settings.token = address(0);
        console01().commandCentre.settings.minBalanceToVote = 0;
        console01().commandCentre.settings.requiredSignaturesInBasisPoints = 10000;
        console01().commandCentre.settings.requiredSupportInBasisPoints = 5000;
        console01().commandCentre.settings.multiSigDuration = 3600 seconds;
        console01().commandCentre.settings.referendumDuration = 1 weeks;
        console01().commandCentre.settings.lockDuration = 3600 seconds;
        console01().commandCentre.settings.signInDuration = 365 days;
        console01().commandCentre.settings.minRequiredActiveOperatorsInBasisPoints = 5000;
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
            if (msg.sender == getAdmin()) {
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