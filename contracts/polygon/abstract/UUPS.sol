// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "contracts/polygon/external/openzeppelin-upgradeable/access/OwnableUpgradeable.sol";

import "contracts/polygon/external/openzeppelin-upgradeable/proxy/utils/Initializable.sol";

import "contracts/polygon/external/openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

abstract contract UUPS is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom: oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer() public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner() override {}
}