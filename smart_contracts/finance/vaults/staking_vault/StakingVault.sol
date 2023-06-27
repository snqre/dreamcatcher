// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/token/ERC20/IERC20.sol";
import "deps/openzeppelin/utils/Address.sol";
import "deps/openzeppelin/utils/Context.sol";
import "deps/openzeppelin/security/ReentrancyGuard.sol";
import "smart_contracts/module_architecture/ModuleManager.sol";

contract StakingVault is Context, ReentrancyGuard {
    address contract_;
    uint rewards;
    uint duration;

    constructor(
        address contract__,
        uint rewards_,
        uint duration_
    ) {
        contract_ = contract__;
        rewards = rewards_;
        duration = duration_;
    }
}