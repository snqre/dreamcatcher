// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";

contract Dream is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {

    /**
    * @dev Constructor for the Dream token contract.
    * @dev Initializes the Dream token with the name "Dream" and symbol "DREAM."
    * @dev Also utilizes the ERC20Permit extension for permit functionality.
    * @dev Upon deployment, mints 200,000,000 Dream tokens to the contract deployer.
    */
    constructor() ERC20("Dream", "DREAM") ERC20Permit("Dream") {
        _mint(msg.sender, 200000000 * (10**18));
    }

    /**
    * @dev External view function to retrieve the current voting snapshot ID.
    * @return uint256 representing the current snapshot ID.
    * @dev This function delegates the retrieval of the current snapshot ID to an internal implementation.
    * @dev It allows external entities to query and obtain the current snapshot ID used for voting.
    */
    function getCurrentSnapshotId() external view returns (uint256) {
        return _getCurrentSnapshotId();
    }

    /**
    * @dev External function to create a new voting snapshot.
    * @return uint256 representing the newly created snapshot ID.
    * @dev This function triggers the creation of a new voting snapshot and returns its ID.
    * @dev It is typically called before starting a new voting round to capture the current state of voting eligibility.
    * @dev The new snapshot ID is obtained immediately after the snapshot is created.
    */
    function snapshot() external returns (uint256) {
        _snapshot();
        return _getCurrentSnapshotId();
    }
    
    /**
    * @dev Internal function invoked before a token transfer.
    * @param from The address from which the tokens are transferred.
    * @param to The address to which the tokens are transferred.
    * @param amount The amount of tokens being transferred.
    * @dev This function is part of the ERC20 and ERC20Snapshot contracts.
    * @dev It ensures that necessary checks and actions are performed before the token transfer.
    */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
}