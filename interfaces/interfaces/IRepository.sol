// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IRepository {
    function getAdmins() external view returns (address[] memory);

    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);

    function getBytes(bytes32 key) external view returns (bytes memory);

    function getUint(bytes32 key) external view returns (uint256);

    function getInt(bytes32 key) external view returns (int256);

    function getAddress(bytes32 key) external view returns (address);

    function getBool(bytes32 key) external view returns (bool);

    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key)
        external
        view
        returns (string[] memory);

    function getBytesArray(bytes32 key) external view returns (bytes[] memory);

    function getUintArray(bytes32 key) external view returns (uint256[] memory);

    function getIntArray(bytes32 key) external view returns (int256[] memory);

    function getAddressArray(bytes32 key)
        external
        view
        returns (address[] memory);

    function getBoolArray(bytes32 key) external view returns (bool[] memory);

    function getBytes32Array(bytes32 key)
        external
        view
        returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint256 index)
        external
        view
        returns (string memory);

    function getIndexedBytesArray(bytes32 key, uint256 index)
        external
        view
        returns (bytes memory);

    function getIndexedUintArray(bytes32 key, uint256 index)
        external
        view
        returns (uint256);

    function getIndexedIntArray(bytes32 key, uint256 index)
        external
        view
        returns (int256);

    function getIndexedAddressArray(bytes32 key, uint256 index)
        external
        view
        returns (address);

    function getIndexedBoolArray(bytes32 key, uint256 index)
        external
        view
        returns (bool);

    function getIndexedBytes32Array(bytes32 key, uint256 index)
        external
        view
        returns (bytes32);

    function getLengthStringArray(bytes32 key) external view returns (uint256);

    function getLengthBytesArray(bytes32 key) external view returns (uint256);

    function getLengthUintArray(bytes32 key) external view returns (uint256);

    function getLengthIntArray(bytes32 key) external view returns (uint256);

    function getLengthAddressArray(bytes32 key) external view returns (uint256);

    function getLengthBoolArray(bytes32 key) external view returns (uint256);

    function getLengthBytes32Array(bytes32 key) external view returns (uint256);

    function getAddressSet(bytes32 key)
        external
        view
        returns (address[] memory);

    function getUintSet(bytes32 key) external view returns (uint256[] memory);

    function getBytes32Set(bytes32 key)
        external
        view
        returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint256 index)
        external
        view
        returns (address);

    function getIndexedUintSet(bytes32 key, uint256 index)
        external
        view
        returns (uint256);

    function getIndexedBytes32Set(bytes32 key, uint256 index)
        external
        view
        returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint256);

    function getLengthUintSet(bytes32 key) external view returns (uint256);

    function getLengthBytes32Set(bytes32 key) external view returns (uint256);

    function addressSetContains(bytes32 key, address value)
        external
        view
        returns (bool);

    function uintSetContains(bytes32 key, uint256 value)
        external
        view
        returns (bool);

    function bytes32SetContains(bytes32 key, bytes32 value)
        external
        view
        returns (bool);

    function addAdmin(address account) external;

    function addLogic(address account) external;

    function removeAdmin(address account) external;

    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;

    function setBytes(bytes32 key, bytes memory value) external;

    function setUint(bytes32 key, uint256 value) external;

    function setInt(bytes32 key, int256 value) external;

    function setAddress(bytes32 key, address value) external;

    function setBool(bytes32 key, bool value) external;

    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(
        bytes32 key,
        uint256 index,
        string memory value
    ) external;

    function setBytesArray(
        bytes32 key,
        uint256 index,
        bytes memory value
    ) external;

    function setUintArray(
        bytes32 key,
        uint256 index,
        uint256 value
    ) external;

    function setIntArray(
        bytes32 key,
        uint256 index,
        int256 value
    ) external;

    function setAddressArray(
        bytes32 key,
        uint256 index,
        address value
    ) external;

    function setBoolArray(
        bytes32 key,
        uint256 index,
        bool value
    ) external;

    function setBytes32Array(
        bytes32 key,
        uint256 index,
        bytes32 value
    ) external;

    function pushStringArray(bytes32 key, string memory value) external;

    function pushBytesArray(bytes32 key, bytes memory value) external;

    function pushUintArray(bytes32 key, uint256 value) external;

    function pushIntArray(bytes32 key, int256 value) external;

    function pushAddressArray(bytes32 key, address value) external;

    function pushBoolArray(bytes32 key, bool value) external;

    function pushBytes32Array(bytes32 key, bytes32 value) external;

    function deleteStringArray(bytes32 key) external;

    function deleteBytesArray(bytes32 key) external;

    function deleteUintArray(bytes32 key) external;

    function deleteIntArray(bytes32 key) external;

    function deleteAddressArray(bytes32 key) external;

    function deleteBoolArray(bytes32 key) external;

    function deleteBytes32Array(bytes32 key) external;

    function addAddressSet(bytes32 key, address value) external;

    function addUintSet(bytes32 key, uint256 value) external;

    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;

    function removeUintSet(bytes32 key, uint256 value) external;

    function removeBytes32Set(bytes32 key, bytes32 value) external;
}