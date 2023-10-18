// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

library DynamicRole {
    struct Role {
        address[] _members;
        uint256 _startTimestamp;
        uint256 _duration;
        uint256 _membersMaxLength;
        bytes32 _roleAdmin;
        bool _isAdmin;
        bool _isTimed;
        bool _resetOnExpiration;
    }

    function members(Role storage self, uint256 id)
    public view
    returns (address) {
        return self._members[id];
    }

    function membersLength(Role storage self)
    public view
    returns (uint256) {
        return self._members.length;
    }

    function isMember(Role storage self, address account)
    public view
    returns (bool) {
        for (uint256 i = 0; i < self._members.length; i++) {
            if (self._members[i] == account) {
                return true;
            }
        }
        return false;
    }

    function startTimestamp(Role storage self)
    public view
    returns (uint256) {
        return self._startTimestamp;
    }

    function duration(Role storage self)
    public view
    returns (uint256) {
        return self._duration;
    }

    function membersMaxLength(Role storage self)
    public view
    returns (uint256) {
        return self._membersMaxLength;
    }

    function roleAdmin(Role storage self)
    public view
    returns (bytes32) {
        return self._roleAdmin;
    }

    function isAdmin(Role storage self)
    public view
    returns (bool) {
        return self._isAdmin;
    }

    function isTimed(Role storage self)
    public view
    returns (bool) {
        return self._isTimed;
    }

    function resetOnExpiration(Role storage self)
    public view
    returns (bool) {
        return self._resetOnExpiration;
    }

    function isAtLimit(Role storage self)
    public view
    returns (bool) {
        return self._members.length >= self._membersMaxLength;
    }

    function expirationTimestamp(Role storage self)
    public view
    returns (uint256) {
        return self._startTimestamp + self._duration;
    }

    function hasStarted(Role storage self)
    public view
    returns (bool) {
        return block.timestamp >= self._startTimestamp;
    }

    function hasExpired(Role storage self)
    public view
    returns (bool) {
        return block.timestamp >= expirationTimestamp(self);
    }

    function isInSession(Role storage self)
    public view
    returns (bool) {
        return hasStarted(self) && !hasExpired(self);
    }

    function secondsLeft(Role storage self)
    public view
    returns (uint256) {
        if (isTimed(self)) {
            if (isInSession(self)) {
                return (self._startTimestamp + self._duration) - block.timestamp;
            }
            else if (!hasStarted(self)) {
                return self._duration;
            }
            else {
                return 0;
            }
        }
        else {
            return 0;
        }
    }

    function grant(Role storage self, address account)
    public {
        require(!isAtLimit(self), "isAtLimit");
        require(!isMember(self, account), "isMember");
        bool success;
        for (uint256 i = 0; i < self._members.length; i++) {
            if (self._members[i] == address(0)) {
                self._members[i] = account;
                success = true;
                break;
            }
        }
        if (!success) {
            self._members.push(account);
        }
    }

    function revoke(Role storage self, address account)
    public {
        require(isMember(self, account), "!isMember");
        for (uint256 i = 0; i < self._members.length; i++) {
            if (self._members[i] == account) {
                self._members[i] = address(0);
                break;
            }
        }
    }

    function resetTimer(Role storage self)
    public {
        self._startTimestamp = block.timestamp;
    }

    function update(Role storage self)
    public {
        if (
            self._isTimed
            && hasExpired(self)
            && self._resetOnExpiration
        ) {
            resetTimer(self);
            delete self._members;
        }
    }
}