// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IVToken } from "./interfaces/standards-native/IVToken.sol";
import { ERC20 } from "./imports/openzeppelin/token/ERC20/ERC20.sol";
import { Ownable } from "./imports/openzeppelin/access/Ownable.sol";

contract VToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol)
    ERC20(name, symbol)
    Ownable(msg.sender)
    {}

    function mint(address account, uint256 amount) public onlyOwner() {
        return _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner() {
        return _burn(account, amount);
    }
}