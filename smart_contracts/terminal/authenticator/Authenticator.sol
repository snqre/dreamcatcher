// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Authenticator is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant BOARD_ROLE = keccak256("BOARD_ROLE");
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    bytes32 public constant SYNDICATE_ROLE = keccak256("SYNDICATE_ROLE");
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(OVERSEER_ROLE, 0x000007c3E0A73f06A64F057e8cfe1848B239A19B);
    }

    function _authorizeUpgrade(address newImplementation) internal override {}

    

    function _mustBeUpgrader() internal view virtual {
        require(hasRole(UPGRADER_ROLE), "Authenticator: caller is not an upgrader");
    }

    function _mustBeOperator() internal view virtual {
        require(hasRole(OPERATOR_ROLE), "Authenticator: caller is not an operator");
    }

    function _mustBeBoard() internal view virtual {
        require(hasRole(BOARD_ROLE), "Authenticator: caller is not a board member");
    }

    function _mustBeDev() internal view virtual {
        require(hasRole(DEV_ROLE), "Authenticator: caller is not a dev");
    }

    function _mustBeSyndicate() internal view virtual {
        require(hasRole(SYNDICATE_ROLE), "Authenticator: caller is not a syndicate");
    }

    function _mustBeMember() internal view virtual {
        require(hasRole(MEMBER_ROLE), "Authenticator: caller is not a member");
    }

}