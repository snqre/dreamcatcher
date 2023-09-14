// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import { ERC20 } from "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";

import { ERC20Burnable } from "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";

import { ERC20Snapshot } from "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";

import { ERC20Permit } from "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";

import { IState } from "contracts/polygon/interfaces/IState.sol";

/**
* standard governance token with minor edit to copy data to state
* if terminal upgrades its state and its no longer logic it doesnt break and can still be used
* this gives us the community to upgrade later or decide to keep this as the functional main token
 */
contract Dream is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    /// State Variables

    IState public state;
    address private _deployer;
    bool private _init;

    bytes32 constant TOTAL_SUPPLY = keccak256("TOTAL_SUPPLY");
    bytes32 constant NAME = keccak256("NAME");
    bytes32 constant SYMBOL = keccak256("SYMBOL");
    bytes32 constant DECIMALS = keccak256("DECIMALS");

    /// Struct, Arrays or Enums

    constructor(address state_) ERC20("Dream Token", symbol) ERC20Permit(name) {
        state = IState(state_);
        _deployer = msg.sender;
        _init = false;
    }

    /// External View

    /** @dev these functions access the state directly to ensure that values allign */
    function stateName() external view returns (string memory) {
        return abi.decode(state.access(NAME), (string));
    }

    function stateSymbol() external view returns (string memory) {
        return abi.decode(state.access(SYMBOL), (string));
    }

    function stateDecimals() external view returns (uint8) {
        return abi.decode(state.access(DECIMALS), (uint8));
    }

    function stateTotalSupply() external view returns (uint256) {
        return abi.decode(state.access(TOTAL_SUPPLY), (uint256));
    }

    function stateBalanceOf(address account) external view returns (uint256) {
        bytes32 account_ = keccak256(abi.encode("account", "balance", account));
        bytes memory data = state.access(account_);
        bytes memory emptyBytes;
        uint256 balance;
        if (data == emptyBytes) { balance = 0; }
        else {
            balance = abi.decode(data, (uint256));
        }
        return balance;
    }

    function getCurrentSnapshotId() external view returns (uint256) {
        return _getCurrentSnapshotId();
    }

    /// External

    function init() external {
        require(msg.sender == _deployer, "Dream: msg.sender != _deployer");
        require(!_init, "Dream: _init");
        state.store(NAME, abi.encode(name));
        state.store(SYMBOL, abi.encode(symbol));
        state.store(DECIMALS, abi.encode(decimals()));
        state.store(TOTAL_SUPPLY, abi.encode(uint256(0)));
        _mint(msg.sender, _convertToWei(200000000));
        _init = true;
    }

    function snapshot() external returns (uint256) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    /// Internal

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
        if (_isLogic) { /// will stop copying data if it is not longer logic without breaking the contract
            if (from == address(0)) {
                _stateAddAccountBalance(to, amount);
                _stateAddTokenTotalSupply(amount);
            }
            else if (to == address(0)) {
                _stateSubAccountBalance(from, amount);
                _stateSubTokenTotalSupply(amount);
            }
            else {
                _stateSubAccountBalance(from, amount);
                _stateAddAccountBalance(to, amount);
            }
        }
    }

    /// Private View

    function _isLogic() private view returns (bool) {
        return address(this) == state.latest();
    }

    function _convertToWei() private view returns (uint256) {
        return value * 10**18;
    }

    /// Private

    function _stateAddAccountBalance(address account, uint256 amount) private {
        bytes32 account = keccak256(abi.encode("account", "balance", account));
        bytes memory data = state.access(account);
        bytes memory emptyBytes;
        uint256 balance;
        if (data == emptyBytes) { balance = 0; }
        else {
            balance = abi.decode(data, (uint256));
        }
        balance += amount;
        state.store(account, abi.encode(balance));
    }

    function _stateSubAccountBalance(address account, uint256 amount) private {
        bytes32 account = keccak256(abi.encode("account", "balance", account));
        bytes memory data = state.access(account);
        bytes memory emptyBytes;
        uint256 balance;
        if (data == emptyBytes) { balance = 0; }
        else {
            balance = abi.decode(data, (uint256));
        }
        balance -= amount;
        state.store(account, abi.encode(balance));
    }

    function _stateAddTokenTotalSupply(uint256 amount) private {
        uint256 supply = abi.decode(state.access(TOTAL_SUPPLY), (uint256));
        supply += amount;
        state.store(TOTAL_SUPPLY, abi.encode(supply));
    }

    function _stateSubTokenTotalSupply(uint256 amount) private {
        uint256 supply = abi.decode(state.access(TOTAL_SUPPLY), (uint256));
        supply -= amount;
        state.store(TOTAL_SUPPLY, abi.encode(supply));
    }
}