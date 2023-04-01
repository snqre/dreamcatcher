// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
/*
The token max supply is uncapped to allow the governor to raise funds
However, it will require proposals and heavy voting to be able to do such a thing
As holders would not be incetizied to do so, unless the proposal was good
If the DAO is making money then they can also burn tokens too
*/

// snapshot governance voting compatibility
// install 0.0.135 vscode solidity extension because latest one doesnt work for imports
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract DreamcatcherToken is ERC20, AccessControl {
    // define the governor address
    // tokens will be trasnfered here first then the governor will have init logic for the team
    address public addressGovernor;

    // token details
    string public stringName = "Dreamcatcher";
    string public stringSymbol = "DREAM";
    uint256 public uint256InitialSupply = 100000;

    constructor() ERC20(stringName, stringSymbol) {
        _mint(addressGovernor, uint256InitialSupply * 10**decimals());
    }
}

// find a way to test this in vscode
