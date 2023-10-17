// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/libraries/shared/errors/Errors.sol";

library DynamicRole {

    /**
    * @title Role
    * @notice A struct representing a role with associated properties.
    * @dev This struct is designed to manage roles within a smart contract,
    *      including details such as name, description, members, and timing properties.
    */
    struct Role {
        string _name;
        string _description;
        uint256 _startTimestamp;
        uint256 _duration;
        uint256 _maxMembersLength;
        address[] _members;
        bytes32 _admin;
        bool _isDefaultAdmin;
        bool _isTimed;
        bool _resetOnExpiration;
    }

    /**
    * @notice Returns the version of the smart contract.
    * @dev Provides the current version number of the smart contract.
    * @return The version number.
    */
    function version(Role storage self) public pure returns (uint256) {
        return 1;
    }

    /**
    * @notice Retrieves the name of the role.
    * @param self The Role struct to query.
    * @return The name of the role.
    */
    function name(Role storage self) public view returns (string memory) {
        return self._name;
    }

    /**
    * @notice Retrieves the description of the role.
    * @param self The Role struct to query.
    * @return The description of the role.
    */
    function description(Role storage self) public view returns (string memory) {
        return self._description;
    }

    /**
    * @notice Retrieves the maximum allowed number of members in the role.
    * @param self The Role struct to query.
    * @return The maximum allowed number of members in the role.
    */
    function maxMembersLength(Role storage self) public view returns (uint256) {
        return self._maxMembersLength;
    }

    /**
    * @notice Retrieves the address of a member in the role based on the member ID.
    * @param self The Role struct to query.
    * @param memberId The ID of the member whose address to retrieve.
    * @return The address of the specified member in the role.
    */
    function members(Role storage self, uint256 memberId) public view returns (address) {
        return self._members[memberId];
    }

    /**
    * @notice Retrieves the current number of members in the role.
    * @param self The Role struct to query.
    * @return The number of members in the role.
    */
    function membersLength(Role storage self) public view returns (uint256) {
        return self._members.length;
    }

    /**
    * @notice Checks if an account has the specified role.
    * @param self The Role struct to query.
    * @param account The address of the account to check.
    * @return True if the account has the role, false otherwise.
    */
    function hasRole(Role storage self, address account) public view returns (bool) {
        for (uint256 i = 0; i < membersLength({self: self}); i++) {
            if (members({self: self, memberId: i}) == account) {
                return true;
            }
        }
        return false;
    }

    /**
    * @notice Retrieves the admin key associated with the role.
    * @param self The Role struct to query.
    * @return The admin key of the role.
    */
    function admin(Role storage self) public view returns (bytes32) {
        return self._admin;
    }

    /**
    * @notice Checks if the role has a default admin.
    * @param self The Role struct to query.
    * @return True if the role has a default admin, false otherwise.
    */
    function isDefaultAdmin(Role storage self) public view returns (bool) {
        return self._isDefaultAdmin;
    }

    /**
    * @notice Checks if the role is timed.
    * @param self The Role struct to query.
    * @return True if the role is timed, false otherwise.
    */
    function isTimed(Role storage self) public view returns (bool) {
        return self._isTimed;
    }

    /**
    * @notice Checks if the role has reached its maximum allowed number of members.
    * @param self The Role struct to query.
    * @return True if the role is at its member limit, false otherwise.
    */
    function isAtLimit(Role storage self) public view returns (bool) {
        return membersLength({self: self}) >= maxMembersLength({self: self});
    }

    /**
    * @notice Checks if the role resets on expiration.
    * @dev Returns true if the role is configured to reset on expiration, otherwise returns false.
    * @param self The Role struct to query.
    * @return True if the role resets on expiration, false otherwise.
    */
    function resetOnExpiration(Role storage self) public view returns (bool) {
        return self._resetOnExpiration;
    }

    /**
    * @notice Sets the name of the role.
    * @dev Allows updating the name of the role.
    * @param self The Role struct to update.
    * @param text The new name to set.
    */
    function setName(Role storage self, string memory text) public {
        self._name = text;
    }

    /**
    * @notice Sets the description of the role.
    * @dev Allows updating the description of the role.
    * @param self The Role struct to update.
    * @param text The new description to set.
    */
    function setDescription(Role storage self, string memory text) public {
        self._description = text;
    }

    /**
    * @notice Sets the maximum allowed number of members in the role.
    * @dev Allows updating the maximum member length of the role.
    * @param self The Role struct to update.
    * @param length The new maximum allowed number of members.
    */
    function setMaxMembersLength(Role storage self, uint256 length) public {
        self._maxMembersLength = length;
    }

    /**
    * @notice Grants a role to a specified account.
    * @dev Adds the account to the role's members if space is available,
    *      otherwise, reverts with an error indicating too many members.
    *      Also reverts if the account already has the role.
    * @param self The Role struct to update.
    * @param account The address of the account to grant the role.
    */
    function grant(Role storage self, address account) public {
        if (isAtLimit({self: self})) {
            revert Errors.TooManyRoleMembers();
        }
        if (hasRole({self: self, account: account})) {
            revert Errors.AlreadyHasRole({account: account});
        }
        bool success;
        for (uint256 i = 0; i < membersLength({self: self}); i++) {
            if (members({self: self, memberId: i}) == address(0)) {
                self._members[i] = account;
                success = true;
                break;
            }
        }
        if (!success) {
            self._members.push(account);
        }
    }

    /**
    * @notice Revokes a role from a specified account.
    * @dev Removes the account from the role's members.
    *      Reverts with an error if the account does not have the role.
    * @param self The Role struct to update.
    * @param account The address of the account to revoke the role from.
    */
    function revoke(Role storage self, address account) public {
        if (!hasRole({self: self, account: account})) {
            revert Errors.DoesNotHaveRole({account: account});
        }
        for (uint256 i = 0; i < membersLength({self: self}); i++) {
            if (members({self: self, memberId: i}) == account) {
                self._members[i] = address(0);
                break;
            }
        }
    }

    /**
    * @notice Sets the admin key for the role.
    * @dev Allows updating the admin key associated with the role.
    * @param self The Role struct to update.
    * @param role The new admin key to set.
    */
    function setAdmin(Role storage self, bytes32 role) public {
        self._admin = role;
    }

    /**
    * @notice Sets whether the role has a default admin.
    * @dev Allows updating the flag indicating if the admin is a default admin.
    * @param self The Role struct to update.
    * @param boolean The boolean value to set for the default admin flag.
    */
    function setDefaultAdmin(Role storage self, bool boolean) public {
        self._isDefaultAdmin = boolean;
    }

    /**
    * @notice Sets whether the role is timed.
    * @dev Allows updating the flag indicating if the role is timed.
    * @param self The Role struct to update.
    * @param boolean The boolean value to set for the timed flag.
    */
    function setTimed(Role storage self, bool boolean) public {
        self._isTimed = boolean;
    }

    /**
    * @notice Sets the reset on expiration flag for the role.
    * @dev Allows updating the flag indicating whether the role should reset on expiration.
    * @param self The Role struct to update.
    * @param boolean The boolean value to set for the reset on expiration flag.
    */
    function setResetOnExpiration(Role storage self, bool boolean) public {
        self._resetOnExpiration = boolean;
    }

    /**
    * @notice Updates the role, resetting it if it is timed, has expired, and is configured to reset on expiration.
    * @dev Checks if the role is timed, has expired, and is configured to reset on expiration.
    *      If all conditions are met, it resets the timer and clears the members.
    * @param self The Role struct to update.
    */
    function update(Role storage self) public {
        if (isTimed({self: self}) && hasExpired({self: self}) && resetOnExpiration({self: self})) {
            resetTimer({self: self});
            delete self._members;
        }
    }

    /** Timer */

    /**
    * @notice Retrieves the start timestamp of the role (if timed).
    * @dev Returns the start timestamp if the role is timed, otherwise returns 0.
    * @param self The Role struct to query.
    * @return The start timestamp of the role.
    */
    function startTimestamp(Role storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return self._startTimestamp;
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Calculates the expiration timestamp of the role (if timed).
    * @dev Returns the expiration timestamp if the role is timed, otherwise returns 0.
    * @param self The Role struct to query.
    * @return The expiration timestamp of the role.
    */
    function expirationTimestamp(Role storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return startTimestamp({self: self}) + duration({self: self});
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Retrieves the duration of the role (if timed).
    * @dev Returns the duration if the role is timed, otherwise returns 0.
    * @param self The Role struct to query.
    * @return The duration of the role.
    */
    function duration(Role storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            return self._duration;
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Checks if the role has started (if timed).
    * @dev Returns true if the role is timed and has started, otherwise returns false.
    * @param self The Role struct to query.
    * @return True if the role has started, false otherwise.
    */
    function hasStarted(Role storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return block.timestamp >= startTimestamp({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Checks if the role has expired (if timed).
    * @dev Returns true if the role is timed and has expired, otherwise returns false.
    * @param self The Role struct to query.
    * @return True if the role has expired, false otherwise.
    */
    function hasExpired(Role storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return block.timestamp >= expirationTimestamp({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Checks if the role is currently in session (if timed).
    * @dev Returns true if the role is timed, has started, and has not expired, otherwise returns false.
    * @param self The Role struct to query.
    * @return True if the role is in session, false otherwise.
    */
    function isInSession(Role storage self) public view returns (bool) {
        if (isTimed({self: self})) {
            return hasStarted({self: self}) && !hasExpired({self: self});
        }
        else {
            return false;
        }
    }

    /**
    * @notice Calculates the remaining seconds of the role (if timed).
    * @dev Returns the remaining time if the role is timed, in session,
    *      the total duration if the role has not started, and 0 if the role has ended.
    * @param self The Role struct to query.
    * @return The remaining seconds on the role.
    */
    function secondsLeft(Role storage self) public view returns (uint256) {
        if (isTimed({self: self})) {
            if (isInSession({self: self})) {
                return (startTimestamp({self: self}) + duration({self: self})) - block.timestamp;
            }
            else if (!hasStarted({self: self})) {
                return duration({self: self});
            }
            else {
                return 0;
            }
        }
        else {
            return 0;
        }
    }

    /**
    * @notice Sets the start timestamp of the role (if timed).
    * @dev Allows updating the start timestamp of the timed role.
    * @param self The Role struct to update.
    * @param timestamp The new start timestamp to set.
    */
    function setStartTimestamp(Role storage self, uint256 timestamp) public {
        self._startTimestamp = timestamp;
    }

    /**
    * @notice Increases the start timestamp of the role by a specified number of seconds (if timed).
    * @dev Allows advancing the start timestamp of the timed role.
    * @param self The Role struct to update.
    * @param seconds_ The number of seconds to increase the start timestamp by.
    */
    function increaseStartTimestamp(Role storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    /**
    * @notice Decreases the start timestamp of the role by a specified number of seconds (if timed).
    * @dev Allows delaying the start timestamp of the timed role.
    * @param self The Role struct to update.
    * @param seconds_ The number of seconds to decrease the start timestamp by.
    */
    function decreaseStartTimestamp(Role storage self, uint256 seconds_) public {
        self._startTimestamp += seconds_;
    }

    /**
    * @notice Sets the duration of the role (if timed).
    * @dev Allows updating the duration of the timed role.
    * @param self The Role struct to update.
    * @param seconds_ The new duration to set.
    */
    function setDuration(Role storage self, uint256 seconds_) public {
        self._duration = seconds_;
    }

    /**
    * @notice Increases the duration of the role by a specified number of seconds (if timed).
    * @dev Allows extending the duration of the timed role.
    * @param self The Role struct to update.
    * @param seconds_ The number of seconds to increase the duration by.
    */
    function increaseDuration(Role storage self, uint256 seconds_) public {
        self._duration += seconds_;
    }

    /**
    * @notice Decreases the duration of the role by a specified number of seconds (if timed).
    * @dev Allows reducing the duration of the timed role.
    * @param self The Role struct to update.
    * @param seconds_ The number of seconds to decrease the duration by.
    */
    function decreaseDuration(Role storage self, uint256 seconds_) public {
        self._duration -= seconds_;
    }

    /**
    * @notice Resets the timer of the timed role.
    * @dev Sets the start timestamp and duration to their default values (0).
    * @param self The Role struct to update.
    */
    function resetTimer(Role storage self) public {
        self._startTimestamp = block.timestamp;
    }
}