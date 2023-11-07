// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/external/openzeppelin/proxy/Proxy.sol';
import 'contracts/polygon/external/openzeppelin/access/AccessControlEnumerable.sol';
import 'contracts/polygon/abstracts/storage/Storage.sol';

contract Base is Storage, Proxy, AccessControlEnumerable {
    address public implementation;

    bytes32 public constant upgrader = keccak256('upgrader');

    event Upgraded(address indexed oldImplementation, address indexed newImplementation);

    function upgradeTo(address newImplementation) external virtual {
        _checkRole(upgrader);
        _upgradeTo(newImplementation);
    }

    function _upgradeTo(address newImplementation) internal virtual {
        address oldImplementation = implementation;
        implementation = newImplementation;
        emit Upgraded(oldImplementation, newImplementation);
    }

    function _implementation() internal view virtual override returns (address) {
        return implementation;
    }

    function configure() external virtual {
        _configure();
    }

    function _configure() internal virtual {
        _grantRole(upgrader, msg.sender);
        _grantRole(admin, msg.sender);
    }
}