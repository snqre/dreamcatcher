// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import "contracts/polygon/deps/openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import "contracts/polygon/deps/openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IRouter {
    
}

contract Router is IRouter, Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}