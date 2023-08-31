// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

interface IToken {
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
}

contract Token is ERC20, Ownable {
    uint maxSupply;

    constructor(string memory name, string memory symbol, uint maxSupply_) 
        ERC20(name, symbol) 
        Ownable(msg.sender) {
        maxSupply = maxSupply_;
    }

    function mint(address account, uint amount)
        public 
        onlyOwner {
        require(amount + totalSupply() <= maxSupply, "Token: max supply reached");
        super._mint(account, amount);
    }

    function burn(address account, uint amount)
        public 
        onlyOwner {
        super._burn(account, amount);
    }
}