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
import "smart_contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "smart_contracts/node_modules/@openzeppelin/contracts/security/PullPayment.sol";

contract Dreamcatcher is ERC20, AccessControl {
    // DIFFERENT TYPES OF ROLES
    // only the custodian can mint tokens
    bytes32 public constant CUSTODIAN = keccak256("CUSTODIAN"); // this is the contract itself responsible for maintaining and assiging roles, the custodian only can mint and control key features
    bytes32 public constant DIRECTOR = keccak256("DIRECTOR"); // ideally head to allow the project to move in a particular direction
    bytes32 public constant BOARD_MEMBER = keccak256("BOARD_MEMBER"); // the board members are elected every x amount of time, these are 6 - 16 people elected and only they can propose actions and stuff that can be voted on
    bytes32 public constant MEMBER = keccak256("MEMBER"); // token holders only they can actively vote and access certain functions

    address public addressCustodian = msg.sender;
    string public stringName = "Dreamcatcher";
    string public stringSymbol = "DREAM";
    uint256 public uint256InitialSupply = 100000;

    /* THIS IS IMPORTANT STUFF THAT CAN BE CHANGED ONLY BY PROPOSAL */
    function giveCustodianRole(address _addressCustodian) private {
        /* give honorary custodian role to an impartial party set by code */
        _setupRole(DEFAULT_ADMIN_ROLE, _addressCustodian);
        _setupRole(CUSTODIAN, _addressCustodian);
    }

    constructor() ERC20(stringName, stringSymbol) {
        // give the contract custodian role
        giveCustodianRole(addressCustodian);

        // generate initial supply for the custodian
        mint(uint256InitialSupply);
    }

    modifier onlyCustodian() {
        require(
            hasRole(CUSTODIAN, msg.sender),
            "Only the Custodian can do this. You must go through a proposal to do this."
        );
        _;
    }
    
    // SNAPSHOT

    // MINTING
    function mintFor(address addressAccount, uint256 uint256Amount)
        public
        onlyCustodian
    {
        /* only the custodian can mint tokens for others */
        /* also has decimals automatically calculated */
        _mint(addressAccount, uint256Amount * 10**decimals());
    }

    function mint(uint256 uint256Amount) public onlyCustodian {
        /* only the custodian can mint tokens for itself */
        /* also has decimals automatically calculated */
        _mint(addressCustodian, uint256Amount * 10**decimals());
    }

    // BURNING
    function burn(uint256 amount) public virtual onlyCustodian {
        /* only the custodian can burn tokens for itself, people can send tokens here if they want to burn them */
        _burn(addressCustodian, amount);
    }

    // PAUSING -- the community can vote to emergency pause if neccesary
}
