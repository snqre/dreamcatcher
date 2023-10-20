// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ITagLite {
    event NameUpdated(string indexed previousName, string indexed newName);

    event NoteUpdated(string indexed previousNote, string indexed newNote);

    event CreatorUpdated(address indexed previousCreator, address indexed newCreator);

    function name() external view returns (string memory);

    function note() external view returns (string memory);

    function creator() external view returns (address);
}