// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/Base.sol";
import "contracts/polygon/interfaces/proxy/IDefaultImplementation.sol";

abstract contract BaseDeployer {

    /** Instance of the deployed Base contract. */
    Base private _deployed;

    /**
    * @dev Constructor to initialize the contract with the provided initial implementation.
    */
    constructor(address defaultImplementation) {
        _deployed = new Base();

        /** Set the initial implementation. */
        _deployed.setInitialImplementation(defaultImplementation);

        /**
        * @dev Unless altered initialize will grant ownership to the deployer
        *      using the default implementation.
         */
        IDefaultImplementation(address(_deployed)).initialize();

        /** Send ownership to the contract deployer. */
        IDefaultImplementation(address(_deployed)).transferOwnership(msg.sender);
    }

    /**
    * @dev Returns the address of the deployed contract.
    */
    function addressDeployedTo() public view virtual returns (address) {
        return address(_deployed);
    }
}