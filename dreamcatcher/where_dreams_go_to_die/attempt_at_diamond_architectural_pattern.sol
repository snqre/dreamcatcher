// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

/** 
    EIP 2535: Dreamcatcher Terminal Polygon|Ethereum 
    DIAMOND ARCHITECTURE BASED ON THE WORK OF: 
        Nick Mudge <nick@perfectabstractions.com>
 */

/**
** IDiamondCut **
* 
enum FacetCutAction {Add, Replace, Remove}
struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
}
function diamondCut(
    FacetCut[] calldata _diamondCut,
    address _init,
    bytes calldata _calldata
) external;
event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
 */
import "https://github.com/mudgen/diamond-3/blob/master/contracts/interfaces/IDiamondCut.sol";


/**
** IDiamondLoupe **
* useful for looking at diamonds
struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}
function facets() external view returns (Facet[] memory facets_);
function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);
function facetAddresses() external view returns (address[] memory facetAddresses_);
function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
 */
import "https://github.com/mudgen/diamond-3/blob/master/contracts/interfaces/IDiamondLoupe.sol";


/**
** IERC173 **
* contract ownership standard
event OwnershipTransferred(address indexed previousOnwer, address indexed newOwner);
function owner() external view returns (address owner_);
function transferOwnership(address _newOwner) external;
 */
import "https://github.com/mudgen/diamond-3/blob/master/contracts/interfaces/IERC173.sol";
import "https://github.com/mudgen/diamond-3/blob/master/contracts/interfaces/IERC165.sol";


/**
** LibDiamond **
 */
import "https://github.com/mudgen/diamond-3/blob/master/contracts/libraries/LibDiamond.sol";

/**
** Diamond **
 */
import "https://github.com/mudgen/diamond-3/blob/master/contracts/Diamond.sol";


library LibDreamcatcher {
    using LibDiamond for LibDiamond.DiamondStorage;

    function addNewFunction(address _diamond, address _newFacetAddress, bytes4 _functionSelector) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.contractOwner() == msg.sender, "LibDreamcatcher: Must be contract owner");

        ds.addFunctions(_newFacetAddress, new bytes4[](_functionSelector));
        ds.initializeDiamondCut(address(this), "");
    }
}

/** Dreamcatcher Terminal */
contract Dreamcatcher is Diamond {
    using LibDreamcatcher for address;
    /**
        Dreamcatcher Contract as Terminal for the rest of the project
     */

    constructor() {
        // set sender as contract owner
        LibDiamond.setContractOwner(msg.sender);

        // initialize with set functions
        address newFacetAddress = address(new NewFacet());
        bytes4 newFunctionSelector = bytes4(keccak256("newFunction()"));
        
        address(this).addNewFunction(newFacetAddress, newFunctionSelector);

        /**
        * set creator as contract owner to allow us to plug in the other facets as we add them
        * once connected we renounce ownership and transfer it to governor
         */

    }
}

// example
/** NewFacet */
contract NewFacet {
    function newFunction() external pure {
        // Your function implementation goes here
    }
}