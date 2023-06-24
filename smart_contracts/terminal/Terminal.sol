// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.9;

/**
    Blockchain > address signature > Server 
    ** locking offchain upgrades through signatures
    ** roles by functions
    ** webDevRole granted role by referendum || implementations go to decentralized github for board to review
    ** once seen by council then signed on
    ** again decentralized github exists??
    ** can link github with cloud flair
    ** commit and confirmation
    ** syndicate, and up can propose changes

    Alex's take
    ** back up is taken of the website and is reviewed
    ** ability to revert back to older updates (situations where this might not be possible)
    ** what if github dies?


    ** snapshot

    implementation of code

    

    once a proposal is approved, it returns a message or something 

    dao legal entity
    blockchain > lawyer > legal contracts
    blockchain > .e<!|| offchain (signature) ||!>e. > decentralized server
                                                    > other blockchains

                                                        ** all of them
                                                        Ethereum + IPFS: 
                                                        Ethereum for data management and IPFS for content hosting.

                                                        • Skynet: 
                                                        Decentralized hosting platform built on the Sia blockchain.

                                                        • Arweave: 
                                                        Blockchain-based storage network for permanent web content hosting.

                                                        • Filecoin: 
                                                        Decentralized storage network that works with IPFS for hosting websites.

                                                        • Storj: 
                                                        Decentralized cloud storage platform that can be used with IPFS for web content hosting.



 */


// need to import these locally to continue this contract

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "deps/openzeppelin/access/AccessControl.sol";

import "smart_contracts/terminal/authenticator/Authenticator.sol";


contract Terminal is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes public constant BOARD_ROLE = keccak256("BOARD_ROLE");
    bytes public constant COUNCIL_ROLE = keccak256("COUNCIL_ROLE");
    bytes public constant DEV_ROLE = keccak256("DEV_ROLE");
    bytes public constant SYNDICATE_ROLE = keccak256("SYNDICATE_ROLE");
    bytes public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");

    mapping(address => bool) private contractWhitelist;

    address safe;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(DEV_ROLE, 0x000007c3E0A73f06A64F057e8cfe1848B239A19B);
    }

    function _authorizeUpgrade(address newImplementation) internal override {}

    function _safeDelegateCall(address contract_, string memory signature, bytes memory args) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        (bool success, ) = address(contract_).delegatecall(abi.encodeWithSignature(signature, args));
        require(success, "Terminal: call was not successful");
        return true;
    }

    fallback() external payable {
        // check if ether or erc20
        // send to safe
        // if value is less than 1 wei means they were likely trying to access a function
    }
    
}