// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/external/openzeppelin/proxy/Proxy.sol";

import "contracts/polygon/abstract/State.sol";

abstract contract Implementation is State, Proxy {

    /** State Variable. */

    /**
    * @dev $ bytes32 with _address storage to store the address of the implementation
     */
    bytes32 public constant $implementation = keccak256("$"); /** NOTE RESERVED: storage use -> _address */

    /**
    * As long as all state and storage slots are preserved then this can be used as a framework.
     */

    /** Proxy. */

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
     * @dev @note This has been overriden here.
     */
    function _implementation() internal view virtual override returns (address) {
        return _address[$implementation];
    }

    /** Internal. */

    function _upgrade(address implementation) internal virtual {
        _address[$implementation] = implementation;
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
        require(_address[$implementation] != address(0), "Terminal: can't fallback to address zero");
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