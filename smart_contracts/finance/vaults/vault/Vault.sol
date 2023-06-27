// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/token/ERC20/IERC20.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";

contract Vault is Context, ReentrancyGuard {
    mapping(address => uint) public amountStaked;

    constructor(address moduleManager) {
        /// using module manager we keep track of any static upgrades.
        IModuleManager(moduleManager).create("vault");
        IModuleManager(moduleManager).upgrade(
            "vault",
            address(this)
        );
    }

    function stake(uint amount) public {
        /// transfer $dream from account to vault
        IERC20(/** $dream contract address. */).transferFrom(
            _msgSender(), 
            address(this),
            amount
        );

        amountStaked[_msgSender()] += amount;
    }
}