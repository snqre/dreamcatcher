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
import "smart_contracts\node_modules@openzeppelincontracts\tokenERC20extensionsERC20Votes.sol";
import "smart_contracts\node_modules@openzeppelincontracts\tokenERC20extensionsERC20Snapshot.sol";
import "smart_contracts\node_modules@openzeppelincontracts\tokenERC20IERC20.sol";
import "smart_contracts\node_modules@openzeppelincontracts\tokenERC20\utilsSafeERC20.sol";
import "smart_contracts\node_modules@openzeppelincontracts\utilsmathSafeMath.sol";

contract Dreamcatcher is ERC20, ERC20Votes, ERC20Snapshot, AccessControl {
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
        snapshot(); // call after minting
    }

    function mint_for(address to, uint256 amount) public {
        /* only the custodian can mint tokens for others */
        /* also has decimals automatically calculated */
        require(
            hasRole(CUSTODIAN, msg.sender),
            "Only the Custodian can mint tokens for others:: must go through proposal"
        );
        _mint(to, amount * 10**decimals());
        snapshot(); // call after minting
    }

    function mint(uint256 amount) public {
        /* only the custodian can mint tokens for itself */
        /* also has decimals automatically calculated */
        require(
            hasRole(CUSTODIAN, msg.sender),
            "Only the Custodian can mint tokens for itself:: must go through proposal"
        );
        _mint(addressCustodian, amount * 10**decimals());
        snapshot();
    }

    function getLastSnapshotId() public view returns (uint256) {
        return latestSnapshot();
    }

    function balanceOfAt(address account, uint256 snapshotId)
        public
        view
        returns (uint256)
    {
        return balanceOfAt(account, snapshotId);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns (uint256) {
        return totalSupplyAt(snapshotId);
    }

    // TREASURY STUFF DRAFT
    function isTokenSupported(
        address addressToken //checks what types of tokens are valid for the treasury
    )
        internal
        view
        returns (
            /* check if we have more than 0 of the token */
            bool
        )
    {
        // check if the token has a balance greater than zero in the cotnract
        uint256 uint256Balance = IERC20(addressToken).balanceOf(address(this));
        if (uint256Balance == 0) {
            //if we dont have any, we dont support it
            return false;
        }

        // if the token passed both checks, it is supported
        return true;
    }

    function getSupportedTokens(address _addressTokenAddress)
        external
        view
        returns (
            /* find all non zero balances useful so we can calculate the value of our treasury vs assets*/
            address[] memory
        )
    {
        IERC20 IERC20Token = IERC20(_addressTokenAddress);
        uint256 uint256TokenCount = IERC20Token.balanceOf(address(this));
        address[] memory addressArrSupportedTokens = new address[](
            uint256TokenCount
        );
        uint256 uint256SupportedTokenIndex = 0;

        for (uint256 i = 0; i < uint256TokenCount; i++) {
            address addressCurrentToken = IERC20Token.tokenOfOwnerByIndex(
                address(this),
                i
            );
            if (isTokenSupported(addressCurrentToken)) {
                addressArrSupportedTokens[
                    uint256SupportedTokenIndex
                ] = addressCurrentToken;
                uint256SupportedTokenIndex++;
            }
        }

        address[] memory addressArrFinalSupportedTokens = new address[](
            uint256SupportedTokenIndex
        );
        for (uint256 i = 0; i < uint256SupportedTokenIndex; i++) {
            addressArrFinalSupportedTokens[i] = addressArrSupportedTokens[i];
        }

        return addressArrFinalSupportedTokens; //return array with all the non zero balance tokens we have in treasury including ours
    }
}
