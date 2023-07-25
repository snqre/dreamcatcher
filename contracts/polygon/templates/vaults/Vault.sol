// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";

/// use average activity to determine safety measures
contract Vault {
    enum State {
        GREEN,
        YELLOW,
        RED
    }

    struct Settings {
        uint maxSizePerTransfer;
    }

    struct Transfer {
        uint timestamp;
        address from;
        address to;
        address token;
        uint amount;
        uint size;
    }

    /// we couldnt possibly think of doing this on ethereum
    Transfer[] public transfers;
    State public state;
    address public hub;
    Settings public settings;
    constructor(address hub_) {
        hub = hub_;
        settings.maxSizePerTransfer = 1000;
    }

    function _getSize(uint amount, uint balance)
        private pure
        returns (uint) {
        return (amount / balance) * 10000;
    }

    function _updateTransfers(uint timestamp, address from, address to, address token, uint amount, uint size)   
        private {
        transfers.push();
        Transfer storage transfer = transfers[transfers.length - 1];
        transfer.timestamp = timestamp;
        transfer.from = from;
        transfer.to = to;
        transfer.token = token;
        transfer.amount = amount;
        transfer.size = size;
    }

    function _updateState(uint size)
        private {
        if (size >= getAverageSize(2592000)) {
            state = State.YELLOW;
        }
    }

    function transferERC20(address target, address to, uint amount)
        public
        returns (bool) {
        uint size = _getSize(amount, IERC20(target).balanceOf(address(this)));
        bool success = IERC20(target).transfer(to, amount);
        require(
            success,
            "Vault: unsuccessful > IERC20(target).transfer(to, amount)"
        );
        _updateTransfers(block.timestamp, address(this), to, target, amount, size);
        _updateState(size);
        return true;
    }

    function transferFromERC20(address target, address from, uint amount)
        public
        returns (bool) {
        IHub(hub).validate(msg.sender, address(this), "transferFrom");
        uint size = _getSize(amount, IERC20(target).balanceOf(address(this)));
        bool success = IERC20(target).transferFrom(from, address(this), amount);
        require(
            success,
            "Vault: unsuccessful > IERC20(target).transferFrom(from, address(this), amount)"
        );
        _updateTransfers(block.timestamp, from, address(this), target, amount, size);
        _updateState(size);
        return true;
    }

    /**
    function getTransfer(uint id)
        public view 
        returns (
            uint,
            address,
            address,
            address,
            uint,
            uint
        ) {
        Transfer storage transfer = transfers[id];
        return (
            transfer.timestamp,
            transfer.from,
            transfer.to,
            transfer.token,
            transfer.amount,
            transfer.size
        );
    }
    */

    function getAverageSize(uint lookBackSeconds)
        public view
        returns (uint) {
        uint sumSize;
        uint checkedTransfers;
        for (uint i = transfers.length - 1; i >= 0; i--) {
            Transfer storage transfer = transfers[i];
            if (transfer.timestamp > (block.timestamp - lookBackSeconds)) {
                sumSize += transfer.size;
                checkedTransfers++;
            }
            else { break; }
        }
        return sumSize / checkedTransfers;
    }
}