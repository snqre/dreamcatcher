// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/proxy-state/ProxyStateV1.sol";

/**
 * @dev Abstract contract for managing upgrade history in a proxy contract.
 * @dev This contract extends `ProxyStateV1` and provides functions for managing upgrade history.
 */
abstract contract ProxyStateHistoryV1 is ProxyStateV1 {

    /**
    * @dev Public pure virtual function to generate a unique key for storing history information.
    * @return bytes32 representing the unique key for history information.
    * @dev This function must be implemented in derived contracts to provide a unique key for history storage.
    */
    function historyKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("HISTORY"));
    }

    /**
    * @dev Public view virtual function to retrieve an array of implementation addresses from history.
    * @return address representing the array of implementation addresses.
    * @dev This function must be implemented in derived contracts to provide the history of implementation addresses.
    */
    function implementations(uint256 id) public view virtual returns (address) {
        return _addressArray[historyKey()][id];
    }

    /**
    * @dev Public view virtual function to retrieve the number of implementations in the upgrade history.
    * @return uint256 representing the length of the array of implementation addresses in history.
    * @dev This function returns the length of the array of implementation addresses in history.
    */
    function implementationsLength() public view virtual returns (uint256) {
        return _addressArray[historyKey()].length;
    }

    /**
    * @dev Internal virtual function to log an upgrade by adding the new implementation address to history.
    * @param implementation The address of the new implementation to be logged.
    * @dev This function must be implemented in derived contracts to log upgrades in history.
    */
    function _logUpgrade(address implementation) internal virtual {
        _addressArray[historyKey()].push(implementation);
    }

    /**
    * @dev Internal virtual function to upgrade the contract to a new implementation.
    * @param implementation The address of the new implementation to upgrade to.
    * @dev This function overrides the parent implementation and ensures that the base contract is upgraded.
    * @dev After upgrading the base contract, it logs the upgrade in history using the `_logUpgrade` function.
    */
    function _upgrade(address implementation) internal virtual override {
        super._upgrade(implementation);
        _logUpgrade(implementation);
    }
}