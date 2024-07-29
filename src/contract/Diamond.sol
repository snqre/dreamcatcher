// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IDiamond } from "./interfaces/standards-native/IDiamond.sol";
import { IFacet } from "./interfaces/standards-native/IFacet.sol";
import { SolidStateDiamond } from "./imports/solidstate-v0.8.24/proxy/diamond/SolidStateDiamond.sol";

contract Diamond is SolidStateDiamond {
    function install(address facet) external virtual onlyOwner() {
        _install(facet);
        return;
    }

    function uninstall(address facet) external virtual onlyOwner() {
        _uninstall(facet);
        return;
    }

    function reinstall(address facet) external virtual onlyOwner() {
        _reinstall(facet);
        return;
    }

    function addSelectors(address facet, bytes4[] memory selectors) external virtual onlyOwner() {
        _addSelectors(facet, selectors);
        return;
    }

    function removeSelectors(bytes4[] memory selectors) external virtual onlyOwner() {
        _removeSelectors(selectors);
        return;
    }

    function replaceSelectors(address facet, bytes4[] memory selectors) public virtual onlyOwner() {
        _replaceSelectors(facet, selectors);
        return;
    }

    function _install(address facet) private {
        IFacet facetInterface = IFacet(facet);
        bytes4[] memory selectors = facetInterface.selectors();
        _addSelectors(facet, selectors);
        return;
    }

    function _uninstall(address facet) private {
        IFacet facetInterface = IFacet(facet);
        bytes4[] memory selectors = facetInterface.selectors();
        _removeSelectors(selectors);
        return;
    }

    function _reinstall(address facet) private {
        IFacet facetInterface = IFacet(facet);
        bytes4[] memory selectors = facetInterface.selectors();
        _replaceSelectors(facet, selectors);
        return;
    }

    function _addSelectors(address facet, bytes4[] memory selectors) private {
        FacetCutAction action = FacetCutAction.ADD;
        FacetCut memory facetCut;
        facetCut.target = facet;
        facetCut.action = action;
        facetCut.selectors = selectors;
        FacetCut[] memory facetCuts = new FacetCut[](1);
        facetCuts[0] = facetCut;
        address noAddress;
        bytes memory noBytes;
        _diamondCut(facetCuts, noAddress, noBytes);
        return;
    }

    function _removeSelectors(bytes4[] memory selectors) private {
        FacetCutAction action = FacetCutAction.REMOVE;
        FacetCut memory facetCut;
        address noAddress;
        bytes memory noBytes;
        facetCut.target = noAddress;
        facetCut.action = action;
        facetCut.selectors = selectors;
        FacetCut[] memory facetCuts = new FacetCut[](1);
        facetCuts[0] = facetCut;
        _diamondCut(facetCuts, noAddress, noBytes);
        return;
    }

    function _replaceSelectors(address facet, bytes4[] memory selectors) private {
        FacetCutAction action = FacetCutAction.REPLACE;
        FacetCut memory facetCut;
        facetCut.target = facet;
        facetCut.action = action;
        facetCut.selectors = selectors;
        FacetCut[] memory facetCuts = new FacetCut[](1);
        facetCuts[0] = facetCut;
        address noAddress;
        bytes memory noBytes;
        _diamondCut(facetCuts, noAddress, noBytes);
        return;
    }
}