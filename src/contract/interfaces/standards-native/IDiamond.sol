// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IErc2535 } from "../standards/IErc2535.sol";

interface IDiamond is IErc2535 {
    function install(address facet) external;
    function uninstall(address facet) external;
    function reinstall(address facet) external;
    function addSelectors(address facet, bytes[] memory selectors) external;
    function removeSelectors(bytes4[] memory selectors) external;
    function replaceSelectors(address facet, bytes4[] memory selectors) external;
}