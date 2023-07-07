// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts\polygon\deps\openzeppelin\access\Ownable.sol";

contract SimpleVault is Ownable {
    constructor() Ownable() {}

    function transfer(address target, address to, uint256 amount)
    external virtual
    returns (bool) {
        bool success = IERC20(target).transfer(to, amount);
        require(success, "SimpleVault: Unable to make transfer.");
        return true;
    }

    function transferFrom(address target, address from, uint256 amount)
    external virtual
    returns (bool) {
        bool success = IERC20(target).transferFrom(from, to, amount);
        require(success, "SimpleVault: Unable to make transfer.");
        return true;
    }
}