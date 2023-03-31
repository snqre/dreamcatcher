// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// snapshot governance voting compatibility
// install 0.0.135 vscode solidity extension because latest one doesnt work for imports
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\ERC20.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\token\ERC20\extensions\ERC20Burnable.sol";
import "smart_contracts\node_modules\@openzeppelin\contracts\access\AccessControl.sol";
import "smart_contracts\node_modules\@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "smart_contracts\node_modules\@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Votes.sol";
import "smart_contracts\node_modules\@openzeppelin/contracts/token/ERC20/extensions/ERC20VotesComp.sol";
contract DreamcatcherToken is 
    ERC20, 
    ERC20Burnable, 
    AccessControl, 
    ERC20Permit, 
    ERC20Votes,
    ERC20VotesComp {
        // management and roles
        address public governor; // governor contract
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
        
        function delegate(address delegatee) public {
            _delegate(msg.sender, delegatee);
        }

        function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) public {
            _delegateBySig(delegatee, nonce, expiry, v, r, s);
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
