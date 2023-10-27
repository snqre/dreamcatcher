// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/Foundation.sol";
import "contracts/polygon/abstract/utils/Initializable.sol";
import "contracts/polygon/abstract/access-control/Ownable.sol";
import "contracts/polygon/abstract/security/Pausable.sol";
import "contracts/polygon/abstract/security/ReentrancyGuard.sol";

contract FoundationImplementation is Foundation, Ownable, Initializable, Pausable, ReentrancyGuard {

    /**
    * @dev Public function to initialize the contract.
    */
    function initialize() public virtual {
        _initialize();
    }

    /**
    * @dev Public function to upgrade the contract's implementation.
    * @param implementation The address of the new implementation contract.
    */
    function upgrade(address implementation) public virtual {
        _onlyOwner();
        _upgrade(implementation);
    }

    function pause() public virtual {
        _onlyOwner();
        _pause();
    }

    function unpause() public virtual {
        _onlyOwner();
        _unpause();
    }

    /**
    * @notice Internal function to initialize the contract.
    * @dev Use this function to perform internal initialization.
    */
    function _initialize() internal virtual override(InitializableLite, OwnableLite) {
        InitializableLite._initialize();
        OwnableLite._initialize();
    }

    function _upgrade(address implementation) internal virtual override {
        _whenPaused();
        super._upgrade(implementation);
    }
}