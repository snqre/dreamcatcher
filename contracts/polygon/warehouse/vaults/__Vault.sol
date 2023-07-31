// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

/// framework to require approval for vault actions which will be connect to multi sig or some mechanism
/// also required that the address that tokens are being sent to is whitelisted
library __Vault {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum Mode {
        SIMPLE,
        REQUIRE_MULTI_SIG,
        LOCKED
    }

    enum State {
        DEFAULT,
        APPROVED,
        REJECTED,
        EXECUTED
    }

    struct Transfer {
        string message;
        address from;
        address to;
        address target;
        uint amount;
        uint size;
        uint startTimestamp;
        uint endTimestamp;
        uint timestamp; /// actual execution timestamp
        State state;
    }

    struct Settings {
        EnumerableSet.AddressSet whitelisted;
        EnumerableSet.AddressSet blacklisted; /// not used
        uint timeout;
    }

    function getSize(uint amount, uint balance)
        public pure
        returns (uint) {
        return (amount / balance) * 10000;
    }

    function requireApproved(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            transfer.state == State.APPROVED,
            "__Vault: transfer has not been approved"
        );
    }

    function requireNotApproved(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            transfer.state != State.APPROVED,
            "__Vault: transfer has been approved"
        );
    }

    function requireRejected(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            transfer.state == State.REJECTED,
            "__Vault: transfer has not been rejected"
        );
    }

    function requireNotRejected(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            transfer.state != State.REJECTED,
            "__Vault: transfer has been rejected"
        );
    }

    function requireExecuted(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            transfer.state == State.EXECUTED,
            "__Vault: transfer has not been executed"
        );
    }

    function requireNotExecuted(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            transfer.state != State.EXECUTED,
            "__Vault: transfer has been executed"
        );
    }

    function requireNotTimedout(Transfer[] storage transfers, uint id)
        public view {
        Transfer storage transfer = transfers[id];
        require(
            block.timestamp > transfer.endTimestamp,
            "__Vault: transfer has timedout"
        );
    }

    function whitelist(Settings storage settings, address account)
        public {

        if (settings.blacklisted.contains(account)) {
            settings.blacklisted.remove(account);
        }

        if (!settings.whitelisted.contains(account)) {
            settings.whitelisted.add(account);
        }
    }

    /**
    function blacklist(Settings storage settings, address account)
        public {
            
        if (settings.whitelisted.contains(account)) {
            settings.whitelisted.remove(account);
        }

        if (!settings.blacklisted.contains(account)) {
            settings.blacklisted.add(account);
        }
    }
    */

    function requireWhitelisted(Settings storage settings, address account)
        public view {
        require(
            settings.whitelisted.contains(account),
            "__Vault: address is not whitelisted"
        );
    }

    function queueTransferERC20(
        Transfer[] storage transfers,
        Settings storage settings,
        string memory message,
        address target,
        address to, 
        uint amount
        ) public {
        requireWhitelisted(settings, to);
        transfers.push();
        Transfer storage transfer = transfers[transfers.length - 1];
        transfer.message = message;
        transfer.from = address(this);
        transfer.to = to;
        transfer.target = target;
        transfer.amount = amount;
        transfer.size = getSize(
            amount,
            IERC20(target).balanceOf(transfer.from)
        );
        transfer.startTimestamp = block.timestamp;
        transfer.endTimestamp = transfer.startTimestamp + settings.timeout;
    }

    function approveTransferERC20(Transfer[] storage transfers, uint id) 
        public {
        requireNotRejected(transfers, id);
        requireNotExecuted(transfers, id);
        requireNotApproved(transfers, id);
        requireNotTimedout(transfers, id);
        Transfer storage transfer = transfers[id];
        transfer.state = State.APPROVED;
    }

    function rejectTransferERC20(Transfer[] storage transfers, uint id)
        public {
        requireNotRejected(transfers, id);
        requireNotExecuted(transfers, id);
        requireNotApproved(transfers, id);
        requireNotTimedout(transfers, id);
        Transfer storage transfer = transfers[id];
        transfer.state = State.REJECTED;
    }

    function executeTransferERC20(Transfer[] storage transfers, uint id)
        public {
        requireApproved(transfers, id);
        requireNotExecuted(transfers, id);
        requireNotTimedout(transfers, id);
        Transfer storage transfer = transfers[id];
        transfer.state = State.EXECUTED;
        transfer.timestamp = block.timestamp;
        bool success = IERC20(transfer.target).transfer(transfer.to, transfer.amount);
        require(success, "__Vault: failed to process transfer");
    }
}