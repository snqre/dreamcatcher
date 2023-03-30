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
        address public admin;
        address public mint;
        address public team = msg.sender;

        bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
        
        constructor()
            ERC20("Dreamcatcher", "DREAM") 
            ERC20Permit("Dreamcatcher") {
                _setupRole(DEFAULT_ADMIN_ROLE, admin);
                _setupRole(MINTER_ROLE, mint);
                _mint(team, 100000 * 10 * decimals());
        }
        
        // minting
        function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
            _mint(to, amount);
        }

}
