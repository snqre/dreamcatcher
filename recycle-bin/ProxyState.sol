// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";

import "contracts/polygon/abstract/State.sol";

/**
 * NOTE WARNING: DO NOT MODIFY STORAGE.
 * NOTE WARNING: DO NOT USE CONSTRUCTOR.
 * NOTE WARNING: _address @ $ is RESERVED.
 */
abstract contract ProxyState is State, Proxy {

    /** Events. */

    /**
    * @dev Upgrade.
     */
    event Upgraded(address indexed implementation);

    /** Proxy. */

    /** External View. */

    /**
    * @dev Returns current implementation.
     */
    function implementation() external view returns (address) {
        return _implementation();
    }

    /** External.  */

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual override {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual override {
        _fallback();
    }

    /** Internal View. */

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     * @dev NOTE This has been overriden here.
     */
    function _implementation() internal view virtual override returns (address) {
        bytes32 location = keccak256(abi.encode("$"));
        return _address[location];
    }

    /** Internal. */

    function _upgrade(address implementation) internal virtual {
        bytes32 location = keccak256(abi.encode("$"));
        _address[location] = implementation;
        emit Upgraded(implementation);
    }

    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual override {
        super._delegate(implementation);
    }

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual override {
        bytes32 location = keccak256(abi.encode("$"));
        require(_address[location] != address(0), "Terminal: fallback to address zero");
        super._fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual override {
        super._beforeFallback();
    }
}