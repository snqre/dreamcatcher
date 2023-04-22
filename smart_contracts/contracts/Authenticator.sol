// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contracts/contracts/State.sol";

interface IAuthenticator {
    event RoleGrantedAdmin(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedAdmin(address indexed _owner);
    event RoleExtendedAdmin(address indexed _owner, uint256 _newDuration);

    event RoleGrantedOperator(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedOperator(address indexed _owner);
    event RoleExtendedOperator(address indexed _owner, uint256 _newDuration);

    event RoleGrantedSyndicate(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedSyndicate(address indexed _owner);
    event RoleExtendedSyndicate(address indexed _owner, uint256 _newDuration);

    event RoleGrantedValidator(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedValidator(address indexed _owner);
    event RoleExtendedValidator(address indexed _owner, uint256 _newDuration);

    event RoleGrantedExtension(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedExtension(address indexed _owner);
    event RoleExtendedExtension(address indexed _owner, uint256 _newDuration);
}

contract Authenticator is State, IAuthenticator {
    event RoleGrantedAdmin(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedAdmin(address indexed _owner);
    event RoleExtendedAdmin(address indexed _owner, uint256 _newDuration);

    event RoleGrantedOperator(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedOperator(address indexed _owner);
    event RoleExtendedOperator(address indexed _owner, uint256 _newDuration);

    event RoleGrantedSyndicate(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedSyndicate(address indexed _owner);
    event RoleExtendedSyndicate(address indexed _owner, uint256 _newDuration);

    event RoleGrantedValidator(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedValidator(address indexed _owner);
    event RoleExtendedValidator(address indexed _owner, uint256 _newDuration);

    event RoleGrantedExtension(address indexed _owner, uint256 _start, uint256 _duration);
    event RoleRevokedExtension(address indexed _owner);
    event RoleExtendedExtension(address indexed _owner, uint256 _newDuration);

    modifier onlyAdmin() {
        address _sender = msg.sender;
        require(
            isAdmin[_sender] == true &&
            expiryAdmin[_sender] <= block.timestamp,
            "onlyAdmin"
        );
        _;
    }

    modifier onlyOperator() {
        address _sender = msg.sender;
        require(
            isOperator[_sender] == true &&
            expiryOperator[_sender] <= block.timestamp,
            "onlyOperator"
        );
        _;
    }

    modifier onlySyndicate() {
        address _sender = msg.sender;
        require(
            isSyndicate[_sender] == true &&
            expirySyndicate[_sender] <= block.timestamp,
            "onlySyndicate"
        );
        _;
    }

    modifier onlyValidator() {
        address _sender = msg.sender;
        require(
            isValidator[_sender] == true &&
            expirySyndicate[_sender] <= block.timestamp,
            "onlyValidator"
        );
        _;
    }

    modifier onlyExtension() {
        address _sender = msg.sender;
        require(
            isExtension[_sender] == true &&
            expiryExtension[_sender] <= block.timestamp,
            "onlyExtension"
        );
    }

    constructor() {
        settings.roles.admin.cur = 0;
        settings.roles.operator.cur = 0;
        settings.roles.syndicate.cur = 0;
        settings.roles.validator.cur = 0;
        settings.roles.extension.cur = 0;

        settings.roles.admin.min = 0;
        settings.roles.operator.min = 0;
        settings.roles.syndicate.min = 0;
        settings.roles.validator.min = 0;
        settings.roles.extension.min = 0;

        settings.roles.admin.max = 1;
        settings.roles.operator.max = 1;
        settings.roles.syndicate.max = 6;
        settings.roles.validator.max = INFINITE;
        settings.roles.extension.max = INFINITE;
    }
    // =.=.=.=.= ADMIN =.=.=.=.=
    function grantRoleAdmin_(address _owner, uint256 _duration) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.admin.max;
        uint256 _min = settings.roles.admin.min;
        uint256 _cur = settings.roles.admin.cur;
        _cur += 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _duration >= 0 &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.admin.cur += 1;
        uint256 _start           = block.timestamp;
        durationAdmin[_owner]    = _duration;
        startAdmin[_owner]       = _start;
        expiryAdmin[_owner]      = _start + _duration;
        isAdmin[_owner]          = true;
        emit RoleGrantedAdmin(_owner, _start, _duration);
        return true;
    }

    function revokeRoleAdmin_(address _owner) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.admin.max;
        uint256 _min = settings.roles.admin.min;
        uint256 _cur = settings.roles.admin.cur;
        _cur -= 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _owner != address(0) &&
            isAdmin[_owner] != false &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.admin.cur -= 1;
        durationAdmin[_owner]    = 0;
        startAdmin[_owner]       = 0;
        expiryAdmin[_owner]      = 0;
        isAdmin[_owner]          = false;
        emit RoleRevokedAdmin(_owner);
        return true;
    }

    function extendRoleAdmin_(address _owner, _duration) internal onlyAdmin returns (bool) {
        require(
            _duration >= 0 &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        (durationAdmin[_owner] += _duration, expiryAdmin[_owner] += _duration);
        emit RoleExtendedAdmin(_owner, expiryAdmin[_owner]);
        return true;
    }
    // =.=.=.=.= OPERATOR =.=.=.=.=
    function grantRoleOperator_(address _owner, uint256 _duration) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.operator.max;
        uint256 _min = settings.roles.operator.min;
        uint256 _cur = settings.roles.operator.cur;
        _cur += 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _duration >= 0 &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.operator.cur += 1;
        uint256 _start           = block.timestamp;
        durationOperator[_owner] = _duration;
        startOperator[_owner]    = _start;
        expiryOperator[_owner]   = _start + _duration;
        isOperator[_owner]       = true;
        emit RoleGrantedOperator(_owner, _start, _duration);
        return true;
    }

    function revokeRoleOperator_(address _owner) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.syndicate.max;
        uint256 _min = settings.roles.syndicate.min;
        uint256 _cur = settings.roles.syndicate.cur;
        _cur -= 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != false &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.operator.cur -= 1;
        durationOperator[_owner]    = 0;
        startOperator[_owner]       = 0;
        expiryOperator[_owner]      = 0;
        isOperator[_owner]          = false;
        emit RoleRevokedOperator(_owner);
        return true;
    }

    function extendRoleOperator_(address _owner, _duration) internal onlyAdmin returns (bool) {
        require(
            _duration >= 0 &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != false &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        (durationOperator[_owner] += _duration, expiryOperator[_owner] += _duration);
        emit RoleExtendedOperator(_owner, expiryOperator[_owner]);
        return true;
    }
    // =.=.=.=.= SYNDICATE =.=.=.=.=
    function grantRoleSyndicate_(address _owner, uint256 _duration) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.syndicate.max;
        uint256 _min = settings.roles.syndicate.min;
        uint256 _cur = settings.roles.syndicate.cur;
        _cur += 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _duration >= 0 &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.syndicate.cur += 1;
        uint256 _start               = block.timestamp;
        durationSyndicate[_owner]    = _duration;
        startSyndicate[_owner]       = _start;
        expirySyndicate[_owner]      = _start + _duration;
        isSyndicate[_owner]          = true;
        emit RoleGrantedSyndicate(_owner, _start, _duration);
        return true;
    }

    function revokeRoleSyndicate_(address _owner) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.syndicate.max;
        uint256 _min = settings.roles.syndicate.min;
        uint256 _cur = settings.roles.syndicate.cur;
        _cur -= 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != false &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.syndicate.cur -= 1;
        durationSyndicate[_owner]    = 0;
        startSyndicate[_owner]       = 0;
        expirySyndicate[_owner]      = 0;
        isSyndicate[_owner]          = false;
        emit RoleRevokedSyndicate(_owner);
        return true;
    }

    function extendRoleSyndicate_(address _owner, _duration) internal onlyAdmin returns (bool) {
        require(
            _duration >= 0 &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != false &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        (durationSyndicate[_owner] += _duration, expirySyndicate[_owner] += _duration);
        emit RoleExtendedSyndicate(_owner, expirySyndicate[_owner]);
        return true;
    }

    // =.=.=.=.= VALIDATOR =.=.=.=.=
    function grantRoleValidator_(address _owner, uint256 _duration) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.validator.max;
        uint256 _min = settings.roles.validator.min;
        uint256 _cur = settings.roles.validator.cur;
        _cur += 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _duration >= 0 &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.validator.cur += 1;
        uint256 _start               = block.timestamp;
        durationValidator[_owner]    = _duration;
        startValidator[_owner]       = _start;
        expiryValidator[_owner]      = _start + _duration;
        isValidator[_owner]          = true;
        emit RoleGrantedValidator(_owner, _start, _duration);
        return true;
    }

    function revokeRoleValidator_(address _owner) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.validator.max;
        uint256 _min = settings.roles.validator.min;
        uint256 _cur = settings.roles.validator.cur;
        _cur -= 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != false &&
            isExtension[_owner] != true
        );
        settings.roles.validator.cur -= 1;
        durationValidator[_owner]    = 0;
        startValidator[_owner]       = 0;
        expiryValidator[_owner]      = 0;
        isValidator[_owner]          = false;
        emit RoleRevokedValidator(_owner);
        return true;
    }

    function extendRoleValidator_(address _owner, _duration) internal onlyAdmin returns (bool) {
        require(
            _duration >= 0 &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != false &&
            isExtension[_owner] != true
        );
        (durationValidator[_owner] += _duration, expiryValidator[_owner] += _duration);
        emit RoleExtendedValidator(_owner, expiryValidator[_owner]);
        return true;
    }
    // =.=.=.=.= EXTENSION =.=.=.=.=
    function grantRoleExtension_(address _owner, uint256 _duration) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.extension.max;
        uint256 _min = settings.roles.extension.min;
        uint256 _cur = settings.roles.extension.cur;
        _cur += 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _duration >= 0 &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != true
        );
        settings.roles.extension.cur += 1;
        uint256 _start               = block.timestamp;
        durationExtension[_owner]    = _duration;
        startExtension[_owner]       = _start;
        expiryExtension[_owner]      = _start + _duration;
        isExtension[_owner]          = true;
        emit RoleGrantedExtension(_owner, _start, _duration);
        return true;
    }

    function revokeRoleExtension_(address _owner) internal onlyAdmin returns (bool) {
        uint256 _max = settings.roles.extension.max;
        uint256 _min = settings.roles.extension.min;
        uint256 _cur = settings.roles.extension.cur;
        _cur -= 1;
        require(
            _cur <= _max &&
            _cur >= _min &&
            _owner != address(0) &&
            isAdmin[_owner] != true &&
            isOperator[_owner] != true &&
            isSyndicate[_owner] != true &&
            isValidator[_owner] != true &&
            isExtension[_owner] != false
        );
        settings.roles.extension.cur -= 1;
        durationExtension[_owner]    = 0;
        startExtension[_owner]       = 0;
        expiryExtension[_owner]      = 0;
        isExtension[_owner]          = false;
        emit RoleRevokedExtension(_owner);
        return true;
    }
}
