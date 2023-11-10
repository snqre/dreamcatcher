// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Permit.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Permit.sol';

interface IGovToken is IERC20Metadata, IERC20Permit {

    /**
    * @dev This will return the current snapshot id which can be used
    *      to check balances and total supply at that snapshot.
     */
    function getCurrentSnapshotId() external view returns (uint);

    /**
    * @dev Takes a snapshot of the current balances and total supply
    *      of the token. This function is public which means anyone
    *      can access it to take a personal snapshot.
     */
    function snapshot() external returns (uint);
}

/**
* @dev The governance token is intended to be used for governance and
*      as a native currency of an ecosystem if required. It adds
*      additional features to the ERC20 standard.
*
* ATTACK SURFACE
* | transfer
* | allowance
* | approve
* | transferFrom
 */
contract GovToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, IGovToken {

    /**
    * @dev Sets the token name, symbol and initial supply. The decimals
    *      is set to 18 which allows for easier transactions and higher
    *      liquidity.
     */
    constructor(string memory name, string memory symbol, uint supply) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, supply * (10**18));
    }

    /**
    * @dev This will return the current snapshot id which can be used
    *      to check balances and total supply at that snapshot.
     */
    function getCurrentSnapshotId() external view virtual returns (uint) {
        return _getCurrentSnapshotId();
    }

    /**
    * @dev Takes a snapshot of the current balances and total supply
    *      of the token. This function is public which means anyone
    *      can access it to take a personal snapshot.
     */
    function snapshot() external virtual returns (uint) {
        return _snapshot();
    }

    /**
    * @dev Required override.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
}