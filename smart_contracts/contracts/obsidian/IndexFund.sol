// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/libraries/Math.sol";
contract Fund is {
    IERC20 internal immutable token;
    uint256 internal totalSupply;
    mapping(address => uint256) internal balanceOf;

    function deposit() external {

    }

    func

    constructor(address _token) {
        token = IERC20(_token);
    }
}
