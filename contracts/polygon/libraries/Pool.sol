// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/libraries/Math.sol";
import "contracts/polygon/solidstate/ERC20/PoolToken.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";

library Pool {

    

    function deposit(address tokenIn, uint amountIn, uint price) internal {
        
    }

    ////////////////////////////////////////////////////////////////////

    /// compute asset balance of vault payable to account assuming amount in is burnt
    function getAssetPayable(address account, uint amountIn, IPoolToken shares, IToken asset) internal view returns (uint) {
        return Math.computeValueOfBWithPercentage(getOwnershipPercentage(account, shares), balance(address(this)), asset);
    }

    /// compute ownership of shares
    function getOwnershipPercentage(address account, IPoolToken shares) internal view returns (uint) {
        /// assume pool token is decimals 10**18
        return Math.computePecentageOfAInB(balance(account, shares), shares.totalSupply());
    }

    ////////////////////////////////////////////////////////////////////

    function balance(address account, IToken asset) internal pure returns (uint) {
        return Math.computeAsStandardValue(asset.balanceOf(account), asset.decimals());
    }

    function balance(address account, IPoolToken asset) internal pure returns (uint) {
        return Math.computeAsStandardValue(asset.balanceOf(account), asset.decimals());
    }
}