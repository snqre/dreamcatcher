// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/solidstate/SigValidator.sol";
import "contracts/polygon/solidstate/Lock.sol";

enum State {
    IS_NONE,
    IS_SIG,
    IS_LOCK,
    IS_DONE
}

interface IConsole {
    event RequestReceived(uint requestId, address[] to, bytes[] data);
    event RequestQueued(uint requestId);
    event RequestPassed(uint requestId);
    event OperatorAdded(address account);
    event OperatorRemoved(address account);
    event SigThresholdChanged(uint oldThreshold, uint newThreshold);
    event SigValidatorDurationChanged(uint oldDuration, uint newDuration);
    event LockDurationChanged(uint oldDuration, uint newDuration);
    event AdminTransferred(address oldAdmin, address newAdmin);

    function ____addOperator(address account) external;
    function ____removeOperator(address account) external;
    function ____setSigThreshold(uint newThreshold) external;
    function ____setSigValidatorDuration(uint newDuration) external;
    function ____setLockDuration(uint newDuration) external;
    function ____transferAdmin(address newAdmin) external;

    function admin() external view returns (address);
    
    function requestsLength() external view returns (uint);

    function requestState(uint requestId) external view returns (State);
    function requestSigDeployed(uint requestId) external view returns (address);
    function requestSigSuccess(uint requestId) external view returns (bool);
    function requestSigBegun(uint requestId) external view returns (bool);

    function requestLockDeployed(uint requestId) external view returns (address);
    function requestLockSuccess(uint requestId) external view returns (bool);
    function requestLockBegun(uint requestId) external view returns (bool);

    function requestTo(uint requestId, uint payloadId) external view returns (address);
    function requestData(uint requestId, uint payloadId) external view returns (bytes memory);
    function requestResponse(uint requestId, uint payloadId) external view returns (bytes memory);
    function payloadLength(uint requestId) external view returns (uint);

    function operators(uint operatorId) external view returns (address);
    function operators() external view returns (address[] memory);
    function operatorsLength() external view returns (uint);
    function isOperator(address account) external view returns (bool);

    function sigThreshold() external view returns (uint);
    function sigValidatorDuration() external view returns (uint);
    function lockDuration() external view returns (uint);

    function activeRequests(uint activeId) external view returns (uint);
    function activeRequests() external view returns (uint[] memory);
    function activeLength() external view returns (uint);
    function isActive(uint requestId) external view returns (bool);

    function passedRequests(uint passedId) external view returns (uint);
    function passedRequests() external view returns (uint[] memory);
    function passedLength() external view returns (uint);
    function isPassed(uint requestId) external view returns (bool);

    function claim() external;

    function request(address[] memory to, bytes[] memory data) external;
    function check(uint requestId) external;
}

contract Console {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 internal constant _CONSOLE = keccak256("slot.console");

    event RequestReceived(uint requestId, address[] to, bytes[] data);
    event RequestQueued(uint requestId);
    event RequestPassed(uint requestId);
    event OperatorAdded(address account);
    event OperatorRemoved(address account);
    event SigThresholdChanged(uint oldThreshold, uint newThreshold);
    event SigValidatorDurationChanged(uint oldDuration, uint newDuration);
    event LockDurationChanged(uint oldDuration, uint newDuration);
    event AdminTransferred(address oldAdmin, address newAdmin);

    struct ConsoleStorage {
        address admin;
        Request[] request;
        EnumerableSet.AddressSet operators;
        uint sigThreshold;
        uint sigValidatorDuration;
        uint lockDuration;
        EnumerableSet.UintSet active;
        EnumerableSet.UintSet passed;
    }

    struct Request {
        address creator;
        State state;
        SigValidator_ msig;
        Lock_ lock;
        address[] to;
        bytes[] data;
        bytes[] response;
    }

    struct Lock_ {
        address deployed;
        bool success;
        bool begun;
    }

    struct SigValidator_ {
        address deployed;
        bool success;
        bool begun;
    }

    function console() internal pure virtual returns (ConsoleStorage storage s) {
        bytes32 location = _CONSOLE;
        assembly {
            s.slot := location
        }
    }

    ///

    function ____addOperator(address account) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        console().operators.add(account);
        emit OperatorAdded(account);
    }

    function ____removeOperator(address account) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        console().operators.remove(account);
        emit OperatorRemoved(account);
    }

    function ____setSigThreshold(uint newThreshold) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        uint oldThreshold = sigThreshold();
        console().sigThreshold = newThreshold;
        emit SigThresholdChanged(oldThreshold, newThreshold);
    }

    function ____setSigValidatorDuration(uint newDuration) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        uint oldDuration = sigValidatorDuration();
        console().sigValidatorDuration = newDuration;
        emit SigValidatorDurationChanged(oldDuration, newDuration);
    }

    function ____setLockDuration(uint newDuration) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        uint oldDuration = lockDuration();
        console().lockDuration = newDuration;
        emit LockDurationChanged(oldDuration, newDuration);
    }

    function ____transferAdmin(address newAdmin) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        _transferAdmin(newAdmin);
    }

    ///

    function admin() public view virtual returns (address) {
        return console().admin;
    }

    ///

    function requestsLength() public view virtual returns (uint) {
        return console().request.length;
    }

    ///

    function requestState(uint requestId) public view virtual returns (State) {
        return console().request[requestId].state;
    }

    function requestSigDeployed(uint requestId) public view virtual returns (address) {
        return console().request[requestId].msig.deployed;
    }

    function requestSigSuccess(uint requestId) public view virtual returns (bool) {
        return console().request[requestId].msig.success;
    }

    function requestSigBegun(uint requestId) public view virtual returns (bool) {
        return console().request[requestId].msig.begun;
    }

    ///

    function requestLockDeployed(uint requestId) public view virtual returns (address) {
        return console().request[requestId].lock.deployed;
    }

    function requestLockSuccess(uint requestId) public view virtual returns (bool) {
        return console().request[requestId].lock.success;
    }

    function requestLockBegun(uint requestId) public view virtual returns (bool) {
        return console().request[requestId].lock.begun;
    }

    ///

    function requestTo(uint requestId, uint payloadId) public view virtual returns (address) {
        return console().request[requestId].to[payloadId];
    }

    function requestData(uint requestId, uint payloadId) public view virtual returns (bytes memory) {
        return console().request[requestId].data[payloadId];
    }

    function requestResponse(uint requestId, uint payloadId) public view virtual returns (bytes memory) {
        return console().request[requestId].data[payloadId];
    }

    function payloadLength(uint requestId) public view virtual returns (uint) {
        return console().request[requestId].to.length;
    }

    ///

    function operators(uint operatorId) public view virtual returns (address) {
        return console().operators.at(operatorId);
    }

    function operators() public view virtual returns (address[] memory) {
        return console().operators.values();
    }

    function operatorsLength() public view virtual returns (uint) {
        return console().operators.length();
    }

    function isOperator(address account) public view virtual returns (bool) {
        return console().operators.contains(account);
    }

    ///

    function sigThreshold() public view virtual returns (uint) {
        return console().sigThreshold;
    }

    function sigValidatorDuration() public view virtual returns (uint) {
        return console().sigValidatorDuration;
    }

    function lockDuration() public view virtual returns (uint) {
        return console().lockDuration;
    }

    ///

    function activeRequests(uint activeId) public view virtual returns (uint) {
        return console().active.at(activeId);
    }

    function activeRequests() public view virtual returns (uint[] memory) {
        return console().active.values();
    }

    function activeLength() public view virtual returns (uint) {
        return console().active.length();
    }

    function isActive(uint requestId) public view virtual returns (bool) {
        return console().active.contains(requestId);
    }

    ///

    function passedRequests(uint passedId) public view virtual returns (uint) {
        return console().passed.at(passedId);
    }

    function passedRequests() public view virtual returns (uint[] memory) {
        return console().passed.values();
    }

    function passedLength() public view virtual returns (uint) {
        return console().passed.length();
    }

    function isPassed(uint requestId) public view virtual returns (bool) {
        return console().passed.contains(requestId);
    }

    ///

    function claim() public virtual {
        require(_adminNotClaimed(), "!_adminNotClaimed");
        _transferAdmin(msg.sender);
    }

    ///

    function request(address[] memory to, bytes[] memory data) public virtual {
        require(isOperator(msg.sender), "!isOperator");
        require(_isSameLengthArr(to, data), "!_isSameLengthArr");
        Request memory newRequest;
        newRequest.creator = msg.sender;
        ISigValidator msig = ISigValidator(address(new SigValidator()));
        for (uint i = 0; i < operatorsLength(); i++) {
            msig.addSigner(operators(i));
        }
        msig.setDuration(sigValidatorDuration());
        msig.setSigThreshold(sigThreshold());
        newRequest.msig.deployed = address(msig);
        ILock lock = ILock(address(new Lock()));
        lock.setDuration(lockDuration());
        newRequest.lock.deployed = address(lock);
        msig.start();
        newRequest.msig.begun = true;
        newRequest.state = State.IS_SIG;
        console().request.push(newRequest);
        console().active.add(requestsLength() - 1);
        emit RequestReceived(requestsLength() - 1, to, data);
    }

    function check(uint requestId) public virtual {
        require(isOperator(msg.sender), "!isOperator");
        if (requestState(requestId) == State.IS_NONE) {
            revert("inactive");
        } else if (requestState(requestId) == State.IS_SIG) {
            if (!requestSigSuccess(requestId)) {
                ISigValidator msig = ISigValidator(requestSigDeployed(requestId));
                if (msig.success()) {
                    Request storage request_ = console().request[requestId];
                    request_.msig.succeess = true;
                    ILock lock = ILock(requestLockDeployed(requestId));
                    lock.start();
                    request_.lock.begun = true;
                    request_.state = State.IS_LOCK;
                    emit RequestQueued(requestId);
                }
            }
        } else if (requestState(requestId) == State.IS_LOCK) {
            if (!requestLockSuccess(requestId)) {
                ILock lock = ILock(requestLockDeployed(requestId));
                lock.check();
                if (lock.success()) {
                    Request storage request_ = console().request[requestId];
                    request_.lock.success = true;
                    request_.state = State.IS_DONE;
                    assert(requestSigBegun(requestId) && requestLockBegun(requestId) && requestSigSuccess(requestId) && requestLockSuccess(requestId));
                    for (uint i = 0; i < payloadLength(); i++) {
                        (bool success, bytes memory response) = address(requestTo(requestId, i)).call(requestData(requestId, i));
                        request_.response[i] = response;
                    }
                    console().active.remove(requestId);
                    console().passed.add(requestId);
                    emit RequestPassed(requestId);
                }
            }
        } else if (requestState(requestId) == State.ISDONE) {
            revert("passed");
        } else {
            revert("unrecognized");
        }
    }

    ///

    function _isInRange(uint value) internal view virtual returns (bool) {
        return value <= 10000;
    }

    function _isSameLengthArr(address[] memory arrayA, bytes[] memory arrayB) internal view virtual returns (bool) {
        return arrayA.length == arrayB.length;
    }

    function _isSelfOrAdmin() internal view virtual returns (bool) {
        return msg.sender == admin() || msg.sender == address(this);
    }

    function _adminNotClaimed() internal view virtual returns (bool) {
        return admin() == address(0);
    }

    function _transferAdmin(address newAdmin) internal virtual {
        uint oldAdmin = admin();
        console().admin = newAdmin;
        emit AdminTransferred(oldAdmin, newAdmin);
    }
}