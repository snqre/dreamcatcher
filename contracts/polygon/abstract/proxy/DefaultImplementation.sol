// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/Base.sol";
import "contracts/polygon/abstract/access-control/Ownable.sol";
import "contracts/polygon/abstract/security/Pausable.sol";

/**
* initializedKey => bool
 */
abstract contract DefaultImplementation is Base, Ownable, Pausable {

    /**
    * @dev Returns the key used to store the initialization status.
    */
    function initializedKey() public pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    /**
    * @dev Returns whether the contract has been initialized.
    */
    function initialized() public view virtual returns (bool) {
        return _bool[initializedKey()];
    }

    /**
    * @dev Upgrades the contract to a new implementation.
    * Can only be called by the owner.
    * @param implementation The address of the new implementation.
    */
    function upgrade(address implementation) public virtual {
        _onlyOwner();
        _upgrade(implementation);
    }

    /**
    * @dev Initializes the contract. 
    * Can only be called if the contract has not been initialized yet.
    */
    function initialize() public virtual {
        require(!initialized(), "DefaultImplementation: initialized()");
        _initialize();
        _bool[initializedKey()] = true;
    }
}