// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface for the IDream token, extending the IERC20Metadata interface.
 * @dev IDream represents a token with additional functionalities related to voting snapshots.
 */
interface IDream is IERC20Metadata {

    /**
    * @dev External function to retrieve the current voting snapshot ID.
    * @return uint256 representing the current snapshot ID.
    * @dev This function allows external entities to query and obtain the current snapshot ID used for voting.
    */
    function getCurrentSnapshotId() external view returns (uint256);

    /**
    * @dev External function to create a new voting snapshot.
    * @return uint256 representing the newly created snapshot ID.
    * @dev This function allows external entities to trigger the creation of a new voting snapshot.
    * @dev It is typically called before starting a new voting round to capture the current state of voting eligibility.
    */
    function snapshot() external returns (uint256);

    /**
    * @dev External view function to retrieve the balance of an account at a specific voting snapshot.
    * @param account The address of the account for which the balance is queried.
    * @param snapshotId The ID of the voting snapshot at which the balance is queried.
    * @return uint256 representing the balance of the specified account at the given snapshot.
    * @dev This function allows external entities to query the historical balance of an account at a specific point in time.
    */
    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);

    /**
    * @dev External view function to retrieve the total supply of voting tokens at a specific voting snapshot.
    * @param snapshotId The ID of the voting snapshot at which the total supply is queried.
    * @return uint256 representing the total supply of voting tokens at the given snapshot.
    * @dev This function allows external entities to query the historical total supply of voting tokens at a specific point in time.
    */
    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);
}