// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IErc20 } from "../standards/IErc20.sol";

interface IVToken is IErc20 {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}