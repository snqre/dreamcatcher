// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBaseDeployer {

    /**
    * @dev Returns the address of the deployed contract.
    */
    function addressDeployedTo() external view returns (address);
}