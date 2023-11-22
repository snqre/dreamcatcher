// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface IPoolToken is IToken {
    function mint(address to, uint amount) external;

    function owner() external view returns (address);

    function renounceOwnership() external;
    function transferOwnership(address newOwner) external;
}

contract PoolToken is Token, Ownable {
    constructor(string memory name, string memory symbol, uint mint_) Token(name, symbol, mint_) Ownable(msg.sender) {}

    function mint(address to, uint amount) onlyOwner external virtual {
        _mint(to, amount);
    }
}