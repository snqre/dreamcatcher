// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/libraries/Command.sol";
import "contracts/polygon/libraries/Utils.sol";
import "contracts/polygon/diamonds/slots/ConsoleFacetSlot/ConsoleFacetSlot01.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/units/20/IToken.sol";

contract ConsoleFacet01 is ConsoleFacetSlot01 {
    using Command for Command.Command_;
    using EnumerableSet for EnumerableSet.AddressSet;

    event OperatorAdded(address operator);
    event OperatorRemoved(address operator);
    event MultiSigDurationChanged(uint oldDuration, uint newDuration);
    event ReferendumDurationChanged(uint oldDuration, uint newDuration);
    event TimelockDurationChanged(uint oldDuration, uint newDuration);
    event NativeTokenChanged(address oldToken, address newToken);
    event RequiredSignaturesInBasisPointsChanged(uint oldValue, uint newValue);
    event RequiredSupportInBasisPointsChanged(uint oldValue, uint newValue);
    event RequiredBalanceToSendCommand(uint oldAmount, uint newAmount);
    event CommandConductChanged(Command.Conduct oldConduct, Command.Conduct newConduct);
    event CommandReceived(uint identifier);
    event CommandSigned(uint identifier, address signer);
    event CommandVoteCasted(uint identifier, address voter, uint weight);

    function ____addOperator(address operator) external virtual {
        Utils.onlySelf();
        console01().operators.add(operator);
        emit OperatorAdded(operator);
    }

    function ____removeOperator(address operator) external virtual {
        Utils.onlySelf();
        console01().operators.remove(operator);
        emit OperatorRemoved(operator);
    }

    function ____setMultiSigDuration(uint newDuration) external virtual {
        Utils.onlySelf();
        uint oldDuration = console01().multiSigDuration;
        console01().multiSigDuration = newDuration;
        emit MultiSigDurationChanged(oldDuration, newDuration);
    }

    function ____setReferendumDuration(uint newDuration) external virtual {
        Utils.onlySelf();
        uint oldDuration = console01().referendumDuration;
        console01().referendumDuration = newDuration;
        emit ReferendumDurationChanged(oldDuration, newDuration);
    }

    function ____setTimelockDuration(uint newDuration) external virtual {
        Utils.onlySelf();
        uint oldDuration = console01().lockDuration;
        console01().lockDuration = newDuration;
        emit TimelockDurationChanged(oldDuration, newDuration);
    }

    function ____setNativeToken(address newToken) external virtual {
        Utils.onlySelf();
        address oldToken = console01().nativeToken;
        console01().nativeToken = newToken;
        emit NativeTokenChanged(oldToken, newToken);
    }

    function ____setRequiredSignaturesInBasisPoints(uint newValue) external virtual {
        Utils.onlySelf();
        uint oldValue = console01().requiredSignaturesInBasisPoints;
        console01().requiredSignaturesInBasisPoints = newValue;
        emit RequiredSignaturesInBasisPointsChanged(oldValue, newValue);
    }

    function ____setRequiredSupportInBasisPoints(uint newValue) external virtual {
        Utils.onlySelf();
        uint oldValue = console01().requiredSupportInBasisPoints;
        console01().requiredSupportInBasisPoints = newValue;
        emit RequiredSupportInBasisPointsChanged(oldValue, newValue);
    }

    function ____setRequiredBalanceToSendCommand(uint newAmount) external virtual {
        Utils.onlySelf();
        uint oldAmount = console01().requiredBalanceToSendCommand;
        console01().requiredBalanceToSendCommand = newAmount;
        emit RequiredBalanceToSendCommand(oldAmount, newAmount);
    }

    function ____setCommandConduct(Command.Conduct newConduct) external virtual {
        Utils.onlySelf();
        Command.Conduct oldConduct = console01().conduct;
        console01().conduct = newConduct;
        emit CommandConductChanged(oldConduct, newConduct);
    }

    function sendCommand(address[] memory targets, bytes[] memory data, bool requireAllCallsSuccessful) public virtual returns (uint) {
        if (!isOperator(Utils.caller())) {
            IToken nativeToken = IToken(getNativeToken());
            require(nativeToken.balanceOf(Utils.caller()) >= getRequiredBalanceToSendCommand(), "Unable to send command because you have insufficient tokens");
        }
        require(targets.length == data.length, "Unable to send command because targets length do not match data length");
        console01().commands.push();
        Command.Command_ storage newCommand = console01().commands[console01().commands.length - 1];
        console01().identifierToCreatorMapping[console01().commands.length - 1] = Utils.caller();
        if (newCommand.conductIsNotSet()) {
            newCommand.chooseConduct(getConsoleConduct());
        }
        if (newCommand.conductIsMultiSigOnly() || newCommand.conductIsMultiSigFirstAndReferendumSecond() || newCommand.conductIsReferendumFirstAndMultiSigSecond()) {
            /// operators are chosen signers
            newCommand.setUpMultiSig(getOperators(), getRequiredSignaturesInBasisPoints(), getMultiSigDuration());
        }
        if (newCommand.conductIsReferendumOnly() || newCommand.conductIsMultiSigFirstAndReferendumSecond() || newCommand.conductIsReferendumFirstAndMultiSigSecond()) {
            newCommand.setUpReferendum(getNativeToken(), getRequiredSupportInBasisPoints(), getReferendumDuration());
        }
        newCommand.setUpTimelock(getTimelockDuration());
        for (uint i = 0; i < targets.length; i ++) {
            newCommand.addPayload(targets[i], data[i]);
        }
        newCommand.setSufficientTimelockDuration(86400 seconds);
        emit CommandReceived(console01().commands.length - 1);
        if (requireAllCallsSuccessful) {
            newCommand.enableRequireAllCallsSuccessful();
        }
        return console01().commands.length - 1;
    }

    function isOperator(address account) public view virtual returns (bool) {
        return console01().operators.contains(account);
    }

    function getOperator(uint identifier) public view virtual returns (address) {
        return console01().operators.at(identifier);
    }

    function getOperators() public view virtual returns (address[] memory) {
        return console01().operators.values();
    }

    function getMultiSigDuration() public view virtual returns (uint) {
        return console01().multiSigDuration;
    }

    function getReferendumDuration() public view virtual returns (uint) {
        return console01().referendumDuration;
    }

    function getTimelockDuration() public view virtual returns (uint) {
        return console01().lockDuration;
    }

    function getNativeToken() public view virtual returns (address) {
        return console01().nativeToken;
    }

    function getRequiredSignaturesInBasisPoints() public view virtual returns (uint) {
        return console01().requiredSignaturesInBasisPoints;
    }

    function getRequiredSupportInBasisPoints() public view virtual returns (uint) {
        return console01().requiredSupportInBasisPoints;
    }

    function getRequiredBalanceToSendCommand() public view virtual returns (uint) {
        return console01().requiredBalanceToSendCommand;
    }

    function getConsoleConduct() public view virtual returns (Command.Conduct) {
        return console01().conduct;
    }

    function getCommandConduct(uint identifier) public view virtual returns (Command.Conduct) {
        return console01().commands[identifier].conduct;
    }

    function getCommandMultiSigNumSigned(uint identifier) public view virtual returns (uint) {
        return console01().commands[identifier].multiSig.numSigned;
    }

    function getCommandMultiSigNumSigners(uint identifier) public view virtual returns (uint) {
        return console01().commands[identifier].multiSig.numSigners;
    }
}