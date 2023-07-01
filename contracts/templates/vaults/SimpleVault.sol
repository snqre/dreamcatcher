// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/deps/openzeppelin/access/Ownable.sol";
import "contracts/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/deps/openzeppelin/token/ERC20/IERC20.sol";

contract SimpleVault is Ownable {
    constructor() Ownable() {}

    function transfer(address target, address to, uint256 amount)
    external
    returns (bool) {
        bool success = IERC20(target).transfer(to, amount);
        require(success, "SimpleVault: Unable to make transfer.");
        return true;
    }

    function transferFrom(address target, address from, uint256 amount)
    external
    returns (bool) {
        bool success = IERC20(target).transferFrom(from, to, amount);
        require(success, "SimpleVault: Unable to make transfer.");
        return true;
    }
}