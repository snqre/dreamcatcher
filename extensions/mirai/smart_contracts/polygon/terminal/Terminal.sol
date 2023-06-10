// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "extensions/mirai/smart_contracts/polygon/pools/single_state_pools/close_ended/single_state_base_class/SingleStateBaseClass.sol";

interface ITerminal {
    event ConnectionEstablished(address indexed contract_, string signature, bytes args);
    event ContractWhitelistEdit(address indexed contract_, bool isWhitelisted);
}

contract Terminal is ITerminal, Initializable, AccessControlUpgradeable, ReentrancyGuard {
    SingleStateBaseClass singleStateBaseClass;

    mapping(address => bool) internal isOnWhitelist;

    

    modifier onlyOnWhitelist(address contract_) {
        require(isOnWhitelist[contract_], "contract is not on whitelist");
        _;
    }

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address dreamToken) initializer public {
        __AccessControl_init();
        singleStateBaseClass = new SingleStateBaseClass();
        singleStateBaseClass.initialize(address(this), dreamToken);
    }

    function _setContractWhitelist(address contract_, bool isWhitelisted) internal {
        isOnWhitelist[contract_] = isWhitelisted;
        emit ContractWhitelistEdit(contract_, isWhitelisted);
    }

    function _connect(address contract_, string memory signature, bytes memory args) internal {
        (bool success, ) = address(contract_).delegatecall(abi.encodeWithSignature(signature, args));
        require(success, "delegatecall failed");
        emit ConnectionEstablished(contract_, signature, args);
    }

    function _safeConnect(address contract_, string memory signature, bytes memory args) internal onlyOnWhitelist(contract_) {
        _connect(contract_, signature, args);
    }

    function connect(address contract_, string memory signature, bytes memory args) public returns (bool) {
        _safeConnect(contract_, signature, args);
        return true;
    }
}