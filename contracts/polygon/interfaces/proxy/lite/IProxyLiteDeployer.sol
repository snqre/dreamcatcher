// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IProxyLiteDeployer {
    event Deployed(address indexed newInstance);

    function deploy(address newImplementation) external returns (address);
}