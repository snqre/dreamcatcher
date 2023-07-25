// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";

contract Token is ERC20, Ownable {
    constructor(string memory name, string memory symbol) 
        ERC20(name, symbol) 
        Ownable(msg.sender) {
        
    }

    function mint(address account, uint amount)
        public 
        onlyOwner {
        super._mint(account, amount);
    }

    function burn(address account, uint amount)
        public 
        onlyOwner {
        super._burn(account, amount);
    }
}