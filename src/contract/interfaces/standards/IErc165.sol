// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;

interface IErc165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}