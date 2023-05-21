// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/TokenHub.sol";
import "blockchain/contracts/Polygon/Pools/Prototype/SingleState/SingleState.sol";

interface ITerminal {
    function connect(address obj, string memory signature, bytes memory args) public returns (bool);
    
    event ConnectionEstablished(
        address indexed obj,
        string memory signature,
        bytes memory args
    );

    event ObjWhitelistEdit(address indexed obj, bool isWhitelisted);
}

contract Terminal is Initializable, AccessControlUpgradeable, ReentrancyGuard, ITerminal {

    TokenHub tokenHub;
    SingleState singleState;

    struct Book {
        address tokenHub;
        address singleState;
    }

    Book book;

    mapping(address => bool) public objWhitelist;

    /** @custom:oz-upgrades-unsafe-allow constructor */
    constructor() {
        tokenHub = new TokenHub();
        singleState = new SingleState();
        book.tokenHub = address(tokenHub);
        book.singleState = address(singleState);
        _setObjWhitelist(address(tokenHub), true);
        _setObjWhitelist(address(singleState), true);
        _disableInitializers();
    }

    function initialize() initializer public {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*---------------------------------------------------------------- PRIVATE **/
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**decimals();
    }

    function _setObjWhitelist(address obj, bool isWhitelisted) internal {
        objWhitelist[obj] = isWhitelisted;
        emit ObjWhitelistEdit(obj, isWhitelisted);
    }

    function _safeConnect(address obj, string memory signature, bytes memory args) internal returns (bool) {
        require(objWhitelist[obj], "Dreamcatcher::_safeConnect: contract not whitelisted");
        /** if there is malicious code that returns true regardless this may fail to protect us */
        (bool success, ) = address(obj).delegatecall(abi.encodeWithSignature(signature, args));
        require(success);

        emit ConnectionEstablished(obj, signature, args);

        return true;
    }

    /*---------------------------------------------------------------- OWNER COMMANDS **/
    function snapshotTokenHub() public onlyOwner returns (bool) {
        (bool success, ) = address(tokenHub).delegatecall(abi.encodeWithSignature("snapshot()", ));
        require(success); abi.encodeWithSignature(signatureString, arg);
        return true;
    }

    /*---------------------------------------------------------------- PUBLIC **/
    function connect(address obj, string memory signature, bytes memory args) public returns (bool) {
        /** users should only be able to call whitelisted contracts */
        bool success = _safeConnect(obj, signature, args);
        return success;
    }

    function createNewPoolSingleState(
        string memory name,
        address[] managers,
        string memory nameToken,
        string memory symbolToken,
        uint256 durationSeconds,
        uint256 requiredInMatic,
        bool isWhitelisted
    ) public payable returns (bool) {
        bytes memory args = abi.encode(
            name,
            managers,
            nameToken,
            symbolToken,
            durationSeconds,
            requiredInMatic,
            isWhitelisted
        );

        address obj = address(singleState);
        string memory signature = "createNewPool(bytes)";
        /** connect . will revert if return is false */
        _safeConnect(obj, signature, args);
        return true;
    }
    
    function contributeSingleState(uint256 id) public payable nonReentrant returns (bool) {
        bytes memory args = abi.encode(id);
        address obj = address(SingleState);
        string memory signature = "contribute(bytes)";
        /** connect . will revert if return is false */
        _safeConnect(obj, signature, args);
        return true;
    }

    function withdrawSingleState(uint256 id, uint256 amount) public nonReentrant returns (bool) {
        bytes memory args = abi.encode(id, amount);
        address obj = address(SingleState);
        string memory signature = "withdraw(bytes)";
        /** connect . will revert if return is false */
        _safeConnect(obj, signature, args);
        return true;
    }
    /** return address */
    function getTokenHub() public view returns (address) {
        return book.tokenHub;
    }

    function getSingleState() public view returns (address) {
        return book.singleState;
    }

}