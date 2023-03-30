// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// snapshot governance voting compatibility
// install 0.0.135 vscode solidity extension because latest one doesnt work for imports
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\ERC20.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\ERC20Burnable.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\access\AccessControl.sol";
import "smart_contracts\node_modules\@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "smart_contracts\node_modules\@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Votes.sol";
contract DreamcatcherToken is 
    ERC20, 
    ERC20Burnable, 
    AccessControl, 
    ERC20Permit, 
    ERC20Votes {
        // management and roles
        address public governor; // governor contract
        address public team = msg.sender;

        // token details
        string public name ="Dreamcatcher";
        string public symbol ="Dream";
        string public initialSupply =100000;
        string public totalSupply =initialSupply;

        constructor()
            ERC20(name, symbol) 
            ERC20Permit(name) {
                _mint(governor, initialSupply * 10 ** decimals());
        }
        
        // allow for proposals to raise funds
        // allow for proposals to do buy backs or burns



        // voting stuff
        function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
            super._beforeTokenTransfer(from, to, amount);
        }

        function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
            super._afterTokenTransfer(from, to, amount);
        }

}
