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
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\ERC20.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\ERC20Burnable.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\access\AccessControl.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\draft-ERC20Permit.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\draft-ERC20Votes.sol";
//
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\TokenSnapshot.sol";

contract DreamcatcherToken is 
    ERC20, 
    ERC20Burnable,
    ERC20Snapshot, 
    AccessControl, 
    ERC20Permit, 
    ERC20Votes {
        // define the governor address
        address public governor;
        address public team =msg.sender;

        // token details
        string public name ="Dreamcatcher";
        string public symbol ="DREAM";
        string public initialSupply =100000;
        string public totalSupply =initialSupply;

        constructor()
            ERC20(name, symbol)
            ERC20Permit(name) {
                _mint(governor, initialSupply * 10 ** decimals());
        }

        // allow for proposals to raise funds
        // allow for proposals to do buy backs or burns

        // do things before the transfer
        function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
            super._beforeTokenTransfer(from, to, amount);
        }

        // do things after
        function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
            super._afterTokenTransfer(from, to, amount);
        }

}
