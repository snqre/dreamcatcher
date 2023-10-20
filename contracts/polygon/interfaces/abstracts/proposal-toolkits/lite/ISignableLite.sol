// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISignableLite {
    event SignerAdded(address indexed account);

    event Signed(address indexed signer);

    function isSigner(address account) external view returns (bool);

    function hasSigned(address account) external view returns (bool);

    function signersCount() external view returns (uint);

    function signaturesCount() external view returns (uint);
}