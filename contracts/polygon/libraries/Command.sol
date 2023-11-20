// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/interfaces/units/20/IToken.sol";

library Command {
    enum Conduct {
        NOT_SET,
        MULTI_SIG_AND_REFERENDUM,
        REFERENDUM_AND_MULTI_SIG,
        REFERENDUM,
        MULTI_SIG,
        NONE
    }

    struct Command_ {
        Conduct conduct;
        MultiSig multiSig;
        Referendum referendum;
        Lock lock;
        Payload[] payloads;
        bool isDone;
        bool requireAllCallsSuccessful;
        uint sufficientTimelockDuration;
    }

    struct Payload {
        address target;
        bytes data;
        bytes response;
        bool success;
    }

    struct Lock {
        bool hasStarted;
        bool isDone;
        Timer timer;
    }

    struct Referendum {
        address token;
        mapping(address => bool) hasVoted;
        mapping(address => uint) weight;
        uint support;
        uint requiredSupportInBasisPoints;
        uint snapshotId;
        bool hasStarted;
        bool isDone;
        Timer timer;
    }

    struct MultiSig {
        mapping(address => bool) isSigner;
        mapping(address => bool) hasSigned;
        uint numSigned;
        uint numSigners;
        bool hasStarted;
        uint requiredSignaturesInBasisPoints;
        bool isDone;
        Timer timer;
    }

    struct Timer {
        uint startTimestamp;
        uint duration;
    }

    function forward(Command_ storage command) internal {
        if (conductIsNotSet(command)) {
            checkValidity(command);
        } else if (conductIsMultiSigFirstAndReferendumSecond(command)) {
            checkValidity(command);
            checkMultiSigHasBeenSetProperly(command);
            checkReferendumHasBeenSetProperly(command);
            checkTimelockHasBeenSetProperly(command);
            if (phaseIsNone(command)) {
                require(!lifeCycleIsComplete(command), "Command life cycle is complete");
                startMultiSigPhase(command, false);
            } else if (phaseIsMultiSig(command)) {
                if (!multiSigConditionsMet(command)) {
                    signCommand(command);
                } else {
                    endMultiSigPhase(command, false);
                    startReferendumPhase(command, true);
                }
            } else if (phaseIsReferendum(command)) {
                if (!referendumConditionsMet(command)) {
                    castVoteOnCommand(command);
                } else {
                    endReferendumPhase(command, true);
                    startTimelockPhase(command, true, true);
                }
            } else if (phaseIsTimelock(command)) {
                endTimelockPhase(command, true, true);
                executeCommand(command, true, true, true);
            }
        } else if (conductIsReferendumFirstAndMultiSigSecond(command)) {
            checkValidity(command);
            checkMultiSigHasBeenSetProperly(command);
            checkReferendumHasBeenSetProperly(command);
            checkTimelockHasBeenSetProperly(command);
            if (phaseIsNone(command)) {
                require(!lifeCycleIsComplete(command), "Command life cycle is complete");
                startReferendumPhase(command, false);
            } else if (phaseIsReferendum(command)) {
                if (!referendumConditionsMet(command)) {
                    castVoteOnCommand(command);
                } else {
                    endReferendumPhase(command, false);
                    startMultiSigPhase(command, true);
                }
            } else if (phaseIsReferendum(command)) {
                if (!multiSigConditionsMet(command)) {
                    signCommand(command);
                } else {
                    endMultiSigPhase(command, true);
                    startTimelockPhase(command, true, true);
                }
            } else if (phaseIsTimelock(command)) {
                endTimelockPhase(command, true, true);
                executeCommand(command, true, true, true);
            }
        } else if (conductIsReferendumOnly(command)) {
            checkValidity(command);
            checkReferendumHasBeenSetProperly(command);
            checkTimelockHasBeenSetProperly(command);
            if (phaseIsNone(command)) {
                require(!lifeCycleIsComplete(command), "Command life cycle is complete");
                startReferendumPhase(command, false);
            } else if (phaseIsReferendum(command)) {
                if (!referendumConditionsMet(command)) {
                    castVoteOnCommand(command);
                } else {
                    endReferendumPhase(command, false);
                    startTimelockPhase(command, true, false);
                }
            } else if (phaseIsTimelock(command)) {
                endTimelockPhase(command, true, false);
                executeCommand(command, true, false, true);
            }
        } else if (conductIsMultiSigOnly(command)) {
            checkValidity(command);
            checkMultiSigHasBeenSetProperly(command);
            checkTimelockHasBeenSetProperly(command);
            if (phaseIsNone(command)) {
                require(!lifeCycleIsComplete(command), "Command life cycle is complete");
                startMultiSigPhase(command, false);
            } else if (phaseIsMultiSig(command)) {
                if (!multiSigConditionsMet(command)) {
                    signCommand(command);
                } else {
                    endMultiSigPhase(command, false);
                    startTimelockPhase(command, false, true);
                }
            } else if (phaseIsTimelock(command)) {
                endTimelockPhase(command, false, true);
                executeCommand(command, false, true, true);
            }
        } else if (conductIsNone(command)) {
            checkValidity(command);
            checkTimelockHasBeenSetProperly(command);
            if (phaseIsNone(command)) {
                require(!lifeCycleIsComplete(command), "Command life cycle is complete");
                startTimelockPhase(command, false, false);
            } else if (phaseIsTimelock(command)) {
                endTimelockPhase(command, false, false);
                executeCommand(command, false, false, true);
            }
        } else {
            revert("Unrecognized conduct");
        }
    }

    function chooseConduct(Command_ storage command, Conduct newConduct) internal {
        require(conductIsNotSet(command), "Unable to proceed because conduct has already been set");
        command.conduct = newConduct;
    }

    function setUpMultiSig(Command_ storage command, address[] memory newSigners, uint newRequiredSignaturesInBasisPoints, uint newDuration) internal {
        require(conductIsMultiSigFirstAndReferendumSecond(command) || conductIsMultiSigOnly(command), "Unable to set up multi sig because the conduct does not require it");
        require(newSigners.length != 0, "Unable to set up multi sig because no signers were given");
        require(newRequiredSignaturesInBasisPoints <= 10000, "Unable to set up multi sig because required signatures must be in basis points but value is above 10000");
        require(newDuration != 0, "Unable to set up multi sig because duration is zero");
        for (uint i = 0; i < newSigners.length; i++) {
            command.multiSig.isSigner[newSigners[i]] = true;
            command.multiSig.numSigners ++;
        }
        command.multiSig.requiredSignaturesInBasisPoints = newRequiredSignaturesInBasisPoints;
        command.multiSig.timer.duration = newDuration;
    }

    function addMultiSigSigner(Command_ storage command, address newSigner) internal {
        require(conductIsMultiSigFirstAndReferendumSecond(command) || conductIsMultiSigOnly(command), "Unable to add multi sig signer because the conduct does not require it");
        command.multiSig.isSigner[newSigner] = true;
        command.multiSig.numSigners ++;
    }

    function setUpReferendum(Command_ storage command, address newToken, uint newRequiredSupportInBasisPoints, uint newDuration) internal {
        require(conductIsReferendumFirstAndMultiSigSecond(command) || conductIsReferendumOnly(command), "Unable to set up referendum because the conduct does not require it");
        require(newToken != address(0), "Unable to set up referendum because token is zero");
        require(newToken.code.length >= 1, "Unable to set up referendum because token is not a contract");
        require(newRequiredSupportInBasisPoints <= 10000, "Unable to set up referendum because required support must be in basis points but value is above 10000");
        require(newDuration != 0, "Unable to set up referendum because duration is zero");
        command.referendum.token = newToken;
        command.referendum.requiredSupportInBasisPoints = newRequiredSupportInBasisPoints;
        command.referendum.timer.duration = newDuration;
    }

    function setUpTimelock(Command_ storage command, uint newDuration) internal {
        require(newDuration != 0, "Unable to set up timelock because duration is zero");
        command.lock.timer.duration = newDuration;
    }

    function addPayload(Command_ storage command, address target, bytes memory data) internal {
        Payload memory newPayload;
        newPayload.target = target;
        newPayload.data = data;
        command.payloads.push(newPayload);
    }

    function castVoteOnCommand(Command_ storage command) internal {
        IToken token = IToken(command.referendum.token);
        require(command.referendum.hasStarted, "Unable to cast vote because referendum phase has not begun");
        require(!command.referendum.isDone, "Unable to cast vote because referendum phase is already done");
        require(!command.referendum.hasVoted[msg.sender], "Unable to cast vote because you have already voted");
        require(token.balanceOfAt(msg.sender, command.referendum.snapshotId) >= 1, "Unable to cast vote because you did not have a sufficient balance when the referendum phase begun");
        command.referendum.hasVoted[msg.sender] = true;
        command.referendum.weight[msg.sender] = token.balanceOfAt(msg.sender, command.referendum.snapshotId);
        command.referendum.support += command.referendum.weight[msg.sender];
    }

    function signCommand(Command_ storage command) internal {
        require(command.multiSig.hasStarted, "Unable to sign multi sig because multi sig phase has not begun");
        require(!command.multiSig.isDone, "Unable to sign multi sig because multi sig phase is already done");
        require(command.multiSig.isSigner[msg.sender], "Unable to sign multi sig because you are not allowed to sign");
        require(!command.multiSig.hasSigned[msg.sender], "Unable to sign multi sig because you have already signed");
        command.multiSig.numSigned ++;
    }

    function setSufficientTimelockDuration(Command_ storage command, uint newSufficientTimelockDuration) internal {
        require(newSufficientTimelockDuration != 0, "Unable to set sufficient timelock duration because value is zero");
        command.sufficientTimelockDuration = newSufficientTimelockDuration;
    }

    function enableRequireAllCallsSuccessful(Command_ storage command) internal {
        command.requireAllCallsSuccessful = true;
    }

    function disableRequireAllCallsSuccessful(Command_ storage command) internal {
        command.requireAllCallsSuccessful = false;
    }

    function startMultiSigPhase(Command_ storage command, bool requireReferendumBefore) internal {
        require(!command.multiSig.hasStarted, "Unable to start multi sig phase because multi sig phase has already begun");
        require(!command.multiSig.isDone, "Unable to start multi sig phase because multi sig phase is already done");
        if (requireReferendumBefore) {
            require(command.referendum.hasStarted && command.referendum.isDone, "Unable to start multi sig phase because this phase requires that a referendum was completed before it");
        }
        command.multiSig.timer.startTimestamp = block.timestamp;
        command.multiSig.hasStarted = true;
    }

    function startReferendumPhase(Command_ storage command, bool requireMultiSigBefore) internal {
        require(!command.referendum.hasStarted, "Unable to start referendum because referendum phase has already begin");
        require(!command.referendum.isDone, "Unable to start referendum because referendum phase is already done");
        if (requireMultiSigBefore) {
            require(command.multiSig.hasStarted && command.multiSig.isDone, "Unable to start referendum phase because this phase requires that a multi sig was completed before it");
        }
        command.referendum.timer.startTimestamp = block.timestamp;
        IToken token = IToken(command.referendum.token);
        command.referendum.snapshotId = token.snapshot();
        command.referendum.hasStarted = true;
    }

    function startTimelockPhase(Command_ storage command, bool requireReferendumBefore, bool requireMultiSigBefore) internal {
        require(!command.lock.hasStarted, "Unable to start timelock because timelock phase has already begun");
        require(!command.lock.isDone, "Unable to start timelock because timelock phase is already done");
        if (requireReferendumBefore) {
            require(command.referendum.hasStarted && command.referendum.isDone, "Unable to start timelock phase because this phase requires that a referendum was completed before it");
        }
        if (requireMultiSigBefore) {
            require(command.multiSig.hasStarted && command.multiSig.isDone, "Unable to start timelock phase because this phase requires that a multi sig was completed before it");
        }
        command.lock.timer.startTimestamp = block.timestamp;
        command.lock.hasStarted = true;
    }

    function endMultiSigPhase(Command_ storage command, bool requireReferendumBefore) internal {
        require(command.multiSig.hasStarted, "Unable to end multi sig phase because multi sig phase has not begun");
        require(!command.multiSig.isDone, "Unable to end multi sig phase because multi sig phase is already done");
        if (requireReferendumBefore) {
            require(command.referendum.hasStarted && command.referendum.isDone, "Unable to end multi sig phase because this phase requires that a referendum was completed before it");
        }
        require(multiSigConditionsMet(command), "Unable to end multi sig phase because its conditions have not been met");
        command.multiSig.isDone = true;
    }

    function endReferendumPhase(Command_ storage command, bool requireMultiSigBefore) internal {
        require(command.referendum.hasStarted, "Unable to end referendum phase because referendum phase has not begun");
        require(!command.referendum.isDone, "Unable to end referendum phase because referendum is already done");
        if (requireMultiSigBefore) {
            require(command.multiSig.hasStarted && command.multiSig.isDone, "Unable to end referendum phase because this phase requires that a multi sig was completed before it");
        }
        require(referendumConditionsMet(command), "Unable to end referendum phase because its conditions have not been met");
        command.referendum.isDone = true;
    }

    function endTimelockPhase(Command_ storage command, bool requireReferendumBefore, bool requireMultiSigBefore) internal {
        require(command.lock.hasStarted, "Unable to end timelock phase because timelock phase has not begun");
        require(!command.lock.isDone, "Unable to end timelock phase because timelock is already done");
        if (requireReferendumBefore) {
            require(command.referendum.hasStarted && command.referendum.isDone, "Unable to start timelock phase because this phase requires that a referendum was completed before it");
        }
        if (requireMultiSigBefore) {
            require(command.multiSig.hasStarted && command.multiSig.isDone, "Unable to start timelock phase because this phase requires that a multi sig was completed before it");
        }
        require(timelockConditionsMet(command), "Unable to end timelock phase because its conditions have not been met");
        command.lock.isDone = true;
    }

    function executeCommand(Command_ storage command, bool requireReferendumBefore, bool requireMultiSigBefore, bool requireTimelockBefore) internal {
        require(!command.isDone, "Unable to execute command because command has already been exected");
        if (requireReferendumBefore) {
            require(command.referendum.hasStarted && command.referendum.isDone, "Unable to execute command because this requires that a referendum was completed before it");
        }
        if (requireMultiSigBefore) {
            require(command.multiSig.hasStarted && command.multiSig.isDone, "Unable to execute command because this requires that a multi sig was completed before it");
        }
        if (requireTimelockBefore) {
            require(command.lock.hasStarted && command.lock.isDone, "Unable to execute command because this requires that a timelock was completed before it");
        }
        command.isDone = true;
        for (uint i = 0; i < command.payloads.length; i++) {
            (bool success, bytes memory response) = address(command.payloads[i].target).call(command.payloads[i].data);
            if (command.requireAllCallsSuccessful) {
                require(success, "Unable to executte command because this required all calls to be successful but at least 1 has failed");
            }
            command.payloads[i].response = response;
            command.payloads[i].success = success;
        }
    }

    function checkMultiSigHasBeenSetProperly(Command_ storage command) internal view {
        require(command.multiSig.numSigners != 0, "Unable to proceed because the conduct requires a multi sig phase but no signers were given");
        require(command.multiSig.timer.duration != 0, "Unable to proceed because the conduct requires a multi sig phase but no duration was given");
        require(command.multiSig.requiredSignaturesInBasisPoints != 0, "Unable to proceed because the conduct requires a multi sig phase but no required signature benchmark was given");
        require(!command.multiSig.hasStarted, "Unable to proceed because the conduct requires a multi sig phase but it may have been compromised leading to an unfair result");
        require(!command.multiSig.isDone, "Unable to proceed because the conduct requires a multi sig phase but it may have been compromised leading to an unfair result");
        require(command.multiSig.timer.startTimestamp == 0, "Unable to proceed because the conduct requires a multi sig phase but it may have been compromised leading to an unfair result");
        require(command.multiSig.numSigned == 0, "Unable to proceed because the conduct requires a mulit sig phase but it may have been compromised leading to an unfair result");
    }

    function checkReferendumHasBeenSetProperly(Command_ storage command) internal view {
        require(command.referendum.token != address(0), "Unable to proceed because the conduct requires a referendum phase but no governance token was given");
        require(command.referendum.timer.duration != 0, "Unable to proceed because the conduct requires a referendum phase but no duration was given");
        require(command.referendum.requiredSupportInBasisPoints != 0, "Unable to proceed because the conduct requires a referendum phase but no required support benchmark was given");
        require(!command.referendum.hasStarted, "Unable to proceed because the conduct requires a referendum phase but it may have been compromised leading to an unfair result");
        require(!command.referendum.isDone, "Unable to proceed because the conduct requires a referendum phase but it may have been compromised leading to an unfair result");
        require(command.referendum.timer.startTimestamp == 0, "Unable to proceed because the conduct requires a referendum phase but it may have been compromised leading to an unfair result");
        require(command.referendum.support == 0, "Unable to proceed because the conduct requires a referendum phase but it may have been compromised leading to an unfair result");
        require(command.referendum.snapshotId == 0, "Unable to proceed because the conduct requires a referendum phase but it may have been compromised leading to an unfair result");
    }

    function checkTimelockHasBeenSetProperly(Command_ storage command) internal view {
        require(command.lock.timer.duration >= command.sufficientTimelockDuration, "Unable to proceed because the command may carry protocol changing behaviour but no timelock duration is an insufficient notice period leading to user threat");
        require(!command.lock.hasStarted, "Unable to proceed because every command requires a timelock but it may have been compromised leading to user threat");
        require(!command.lock.isDone, "Unable to proceed because every command requires a timelock but it may have been compromised leading to user threat");
        require(command.lock.timer.startTimestamp == 0, "Unable to proceed because every command requires a timelock but it may have been compromised leading to user threat");
    }

    function checkValidity(Command_ storage command) internal view {
        require(command.conduct != Conduct.NOT_SET, "Unable to proceed because conduct has not been set");
        require(!command.isDone, "Unable to proceed because the command may have been compromised");
    }

    function conductIsNotSet(Command_ storage command) internal view returns (bool) {
        return command.conduct == Conduct.NOT_SET;
    }

    function conductIsMultiSigFirstAndReferendumSecond(Command_ storage command) internal view returns (bool) {
        return command.conduct == Conduct.MULTI_SIG_AND_REFERENDUM;
    }

    function conductIsReferendumFirstAndMultiSigSecond(Command_ storage command) internal view returns (bool) {
        return command.conduct == Conduct.REFERENDUM_AND_MULTI_SIG;
    }

    function conductIsReferendumOnly(Command_ storage command) internal view returns (bool) {
        return command.conduct == Conduct.REFERENDUM;
    }

    function conductIsMultiSigOnly(Command_ storage command) internal view returns (bool) {
        return command.conduct == Conduct.MULTI_SIG;
    }

    function conductIsNone(Command_ storage command) internal view returns (bool) {
        return command.conduct == Conduct.NONE;
    }

    function phaseIsNone(Command_ storage command) internal view returns (bool) {
        bool noMultiSigSessionIsRunning;
        bool noReferendumSessionIsRunning;
        bool noTimelockIsRunning;
        if (command.multiSig.hasStarted) {
            if (command.multiSig.isDone) {
                noMultiSigSessionIsRunning = true;
            }
            noMultiSigSessionIsRunning = false;
        } else {
            noMultiSigSessionIsRunning = true;
        }
        if (command.referendum.hasStarted) {
            if (command.referendum.isDone) {
                noReferendumSessionIsRunning = true;
            }
            noReferendumSessionIsRunning = false;
        } else {
            noReferendumSessionIsRunning = true;
        }
        if (command.lock.hasStarted) {
            if (command.lock.isDone) {
                noTimelockIsRunning = true;
            }
            noTimelockIsRunning = false;
        } else {
            noTimelockIsRunning = true;
        }
        return !noMultiSigSessionIsRunning && !noReferendumSessionIsRunning && !noTimelockIsRunning;
    }

    function phaseIsMultiSig(Command_ storage command) internal view returns (bool) {
        if (command.multiSig.hasStarted) {
            if (command.multiSig.isDone) {
                return false;
            }
            return true;
        }
        return false;
    }

    function phaseIsReferendum(Command_ storage command) internal view returns (bool) {
        if (command.referendum.hasStarted) {
            if (command.referendum.isDone) {
                return false;
            }
            return true;
        }
        return false;
    }

    function phaseIsTimelock(Command_ storage command) internal view returns (bool) {
        if (command.lock.hasStarted) {
            if (command.lock.isDone) {
                return false;
            }
            return true;
        }
        return false;
    }

    function multiSigConditionsMet(Command_ storage command) internal view returns (bool) {
        return block.timestamp < command.multiSig.timer.startTimestamp + command.multiSig.timer.duration && command.multiSig.numSigned >= (command.multiSig.numSigners * command.multiSig.requiredSignaturesInBasisPoints) / 10000;
    }

    function referendumConditionsMet(Command_ storage command) internal view returns (bool) {
        IToken token = IToken(command.referendum.token);
        return block.timestamp < command.referendum.timer.startTimestamp + command.referendum.timer.duration && command.referendum.support >= (token.totalSupply() * command.referendum.requiredSupportInBasisPoints) / 10000;
    }

    function timelockConditionsMet(Command_ storage command) internal view returns (bool) {
        return block.timestamp >= command.lock.timer.startTimestamp + command.lock.timer.duration;
    }

    function lifeCycleIsComplete(Command_ storage command) internal view returns (bool) {
        return command.isDone;
    }
}