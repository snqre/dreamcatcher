// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

interface IRepository {
    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);
    function getBytes(bytes32 key) external view returns (bytes memory);
    function getUint(bytes32 key) external view returns (uint);
    function getInt(bytes32 key) external view returns (int);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key) external view returns (string[] memory);
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint index) external view returns (string memory);
    function getIndexedBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function getIndexedUintArray(bytes32 key, uint index) external view returns (uint);
    function getIndexedIntArray(bytes32 key, uint index) external view returns (int);
    function getIndexedAddressArray(bytes32 key, uint index) external view returns (address);
    function getIndexedBoolArray(bytes32 key, uint index) external view returns (bool);
    function getIndexedBytes32Array(bytes32 key, uint index) external view returns (bytes32);
    
    function getLengthStringArray(bytes32 key) external view returns (uint);
    function getLengthBytesArray(bytes32 key) external view returns (uint);
    function getLengthUintArray(bytes32 key) external view returns (uint);
    function getLengthIntArray(bytes32 key) external view returns (uint);
    function getLengthAddressArray(bytes32 key) external view returns (uint);
    function getLengthBoolArray(bytes32 key) external view returns (uint);
    function getLengthBytes32Array(bytes32 key) external view returns (uint);

    function getAddressSet(bytes32 key) external view returns (address[] memory);
    function getUintSet(bytes32 key) external view returns (uint[] memory);
    function getBytes32Set(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint index) external view returns (address);
    function getIndexedUintSet(bytes32 key, uint index) external view returns (uint);
    function getIndexedBytes32Set(bytes32 key, uint index) external view returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint);
    function getLengthUintSet(bytes32 key) external view returns (uint);
    function getLengthBytes32Set(bytes32 key) external view returns (uint);
    
    function addressSetContains(bytes32 key, address value) external view returns (bool);
    function uintSetContains(bytes32 key, uint value) external view returns (bool);
    function bytes32SetContains(bytes32 key, bytes32 value) external view returns (bool);

    function addAdmin(address account) external;
    function addLogic(address account) external;
    
    function removeAdmin(address account) external;
    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;
    function setBytes(bytes32 key, bytes memory value) external;
    function setUint(bytes32 key, uint value) external;
    function setInt(bytes32 key, int value) external;
    function setAddress(bytes32 key, address value) external;
    function setBool(bytes32 key, bool value) external;
    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(bytes32 key, uint index, string memory value) external;
    function setBytesArray(bytes32 key, uint index, bytes memory value) external;
    function setUintArray(bytes32 key, uint index, uint value) external;
    function setIntArray(bytes32 key, uint index, int value) external;
    function setAddressArray(bytes32 key, uint index, address value) external;
    function setBoolArray(bytes32 key, uint index, bool value) external;
    function setBytes32Array(bytes32 key, uint index, bytes32 value) external;

    function pushStringArray(bytes32 key, string memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function pushIntArray(bytes32 key, int value) external;
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
    function addUintSet(bytes32 key, uint value) external;
    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
}

interface ISolsticeSafeguardBeta {
    function isAdmin(address account) external view returns (bool);
    function isManager(address account) external view returns (bool);
    function isContributor(address account) external view returns (bool);
    function getAdmins() external view returns (address[] memory);
    function getManagers() external view returns (address[] memory);
    function getContributors() external view returns (address[] memory);
    function getName() external view returns (string memory);
    function getDescription() external view returns (string memory);
    function getContribution(address account) external view returns (uint);
    function addAdmin(address account) external;
    function addManager(address account) external;
    function addContributor(address account) external;
    function removeAdmin(address account) external;
    function removeManager(address account) external;
    function removeContributor(address account) external;
    function setName(string memory newName) external;
    function setDescription(string memory newDescription) external;
    function setContribution(address account, uint newContribution) external;
}

/** storage usage
    _addressSet     "solsticeBeta", <addr/msg.sender>, "admins"
    _addressSet     "solsticeBeta", <addr/msg.sender>, "managers"
    _addressSet     "solsticeBeta", <addr/msg.sender>, "contributors"
    _string         "solsticeBeta", <addr/msg.sender>, "name"
    _string         "solsticeBeta", <addr/msg.sender>, "description"
    _uint           "solsticeBeta", <addr/msg.sender>, <addr/account>, "contribution"
 */
contract SolsticeSafeguardBeta is ISolsticeSafeguardBeta {
    IRepository public repository;
    

    modifier onlySolsticeBeta {
        _onlySolsticeBeta();
        _;
    }

    constructor() {
        repository = IRepository(0xE2578e92fB2Ba228b37eD2dFDb1F4444918b64Aa);
    }

    function isAdmin(address account)
    public view
    onlySolsticeBeta
    returns (bool) {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        return repository.addressSetContains(admins, account);
    }

    function isManager(address account)
    public view
    onlySolsticeBeta
    returns (bool) {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        return repository.addressSetContains(managers, account);
    }

    function isContributor(address account)
    public view
    onlySolsticeBeta
    returns (bool) {
        bytes32 contributors = keccak256(abi.encode("solsticeBeta", msg.sender, "contributors"));
        return repository.addressSetContains(contributors, account);
    }

    function getAdmins()
    public view
    onlySolsticeBeta
    returns (address[] memory) {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        return repository.getAddressSet(admins);
    }

    function getManagers()
    public view
    onlySolsticeBeta
    returns (address[] memory) {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        return repository.getAddressSet(managers);
    }

    function getContributors()
    public view
    onlySolsticeBeta
    returns (address[] memory) {
        bytes32 contributors = keccak256(abi.encode("solsticeBeta", msg.sender, "contributors"));
        return repository.getAddressSet(contributors);
    }

    function getName()
    public view
    onlySolsticeBeta
    returns (string memory) {
        bytes32 name = keccak256(abi.encode("solsticeBeta", msg.sender, "name"));
        return repository.getString(name);
    }

    function getDescription()
    public view
    onlySolsticeBeta
    returns (string memory) {
        bytes32 description = keccak256(abi.encode("solsticeBeta", msg.sender, "description"));
        return repository.getString(description);
    }

    function getContribution(address account)
    public view
    onlySolsticeBeta
    returns (uint) {
        bytes32 contribution = keccak256(abi.encode("solsticeBeta", msg.sender, account, "contribution"));
        return repository.getUint(contribution);
    }

    function getNetAssetValue()
    public view
    onlySolsticeBeta
    returns (uint) {
        bytes32 netAssetValue = keccak256(abi.encode("solsticeBeta", msg.sender, "netAssetValue"));
        return repository.getUint(netAssetValue);
    }

    function addAdmin(address account)
    public 
    onlySolsticeBeta {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        repository.addAddressSet(admins, account);
    }

    function addManager(address account)
    public 
    onlySolsticeBeta {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        repository.addAddressSet(managers, account);
    }

    function addContributor(address account)
    public 
    onlySolsticeBeta {
        bytes32 contributors = keccak256(abi.encode("solsticeBeta", msg.sender, "contributors"));
        repository.addAddressSet(contributors, account);
    }

    function removeAdmin(address account)
    public 
    onlySolsticeBeta {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        repository.removeAddressSet(admins, account);
    }

    function removeManager(address account)
    public 
    onlySolsticeBeta {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        repository.removeAddressSet(managers, account);
    }

    function removeContributor(address account)
    public 
    onlySolsticeBeta {
        bytes32 contributors = keccak256(abi.encode("solsticeBeta",msg.sender,"contributors"));
        repository.removeAddressSet(contributors, account);
    }

    function setName(string memory newName)
    public 
    onlySolsticeBeta {
        bytes32 name = keccak256(abi.encode("solsticeBeta",msg.sender,"name"));
        repository.setString(name, newName);
    }

    function setDescription(string memory newDescription)
    public 
    onlySolsticeBeta {
        bytes32 description = keccak256(abi.encode("solsticeBeta", msg.sender, "description"));
        repository.setString(description, newDescription);
    }

    function setContribution(address account, uint newContribution)
    public 
    onlySolsticeBeta {
        bytes32 contribution = keccak256(abi.encode("solsticeBeta", msg.sender, account, "contribution"));
        repository.setUint(contribution, newContribution);
    }

    function setNetAssetValue(uint newNetAssetValue)
    public
    onlySolsticeBeta {
        bytes32 netAssetValue = keccak256(abi.encode("solsticeBeta", msg.sender, "netAssetValue"));
        return repository.setUint(netAssetValue, newNetAssetValue);
    }

    function _onlySolsticeBeta()
    internal view {
        bytes32 solsticeBetaContracts = keccak256(abi.encode("solsticeBeta", "solsticeBetaContracts"));
        bool isSolsticeBetaContract = repository.addressSetContains(solsticeBetaContracts, msg.sender);
        require(isSolsticeBetaContract, "SolsticeSafeguardBeta: caller is not a solstice beta contract");
    }
}