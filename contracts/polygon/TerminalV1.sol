// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/utils/Context.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

import "contracts/polygon/ProxyStateOwnableContract.sol";

/**
* version 0.5.0
*
* @dev A component is like a part that works in the protocol. Components 
*      often talk to other components, making the protocol interactions 
*      complex and hard to follow. The Terminal is in charge of improving 
*      our proxies. It helps the protocol handle its owned proxies in an 
*      organized way. It displays different states like supported, 
*      unsupported, paused, unpaused, and more. It also enables multiple 
*      upgrades to happen in a single transaction.
 */
contract TerminalV1 is ProxyStateOwnableContract {

    /** Events. */

    event ComponentDeployed(string indexed name, address indexed component);

    event ComponentUpgraded(string indexed name, address indexed component, address indexed implementation);

    /** Internal View. */

    function _stringToAddressMapping(string memory name) internal view returns (uint256 index) {
        bytes memory refBytes = abi.encode(name);
        bytes32 ref = keccak256(refBytes);
        return _address[ref];
    }

    /** Internal. */

    function _assignStringToAddressMapping(string memory name, address component) internal {
        bytes memory refBytes = abi.encode(name);
        bytes32 ref = keccak256(refBytes);
        _address[ref] = component;
    }

    function _storeUpgrade(string memory name, address implementation) internal {
        address component = _stringToAddressMapping(name);
        bytes memory refBytes = abi.encode(component, "history");
        bytes32 ref = keccak256(refBytes);
        _addressArray[ref].push(implementation);
    }

    function _deployComponent(string memory name) internal {
        bytes memory refBytes = abi.encode("components");
        bytes32 ref = keccak256(refBytes);
        EnumerableSet.AddressSet storage components = _addressSet[ref];
        components.add(new ProxyStateOwnableContract());
        uint256 index = components.length() - 1;
        IProxyStateOwnable component = IProxyStateOwnable(components.at(index));
        _assignStringToAddressMapping(name, address(component));
        emit ComponentDeployed(name, address(component));
    }

    function _upgradeComponent(string memory name, address implementation) internal {
        IProxyStateOwnable component = IProxyStateOwnable(_stringToAddressMapping(name));
        component.pause();
        component.upgrade(implementation);
        component.unpause();
        _storeUpgrade(name, implementation);
        emit ComponentUpgraded(name, address(component), implementation);
    }
}