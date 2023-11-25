// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/libraries/Finance.sol";
import "contracts/polygon/solidstate/ERC20/PoolToken.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";

library Pool {
    using Finance for uint;

    /// compute total assets
    function computeTotalAssets(address[] memory assets, uint[] memory amounts, uint[] memory prices) internal pure returns (uint) {
        require(assets.length != 0, "Length is zero");
        require(amounts.length != 0, "Length is zero");
        require(prices.length != 0, "Length is zero");
        require(assets.length == amounts.length, "Unequal");
        require(amounts.length == prices.length, "Unequal");
        require(prices.length == assets.length, "Unequal");
        uint sum;
        for (uint i = 0; i < assets.length; i++) {
            sum += computeValue(amounts[i], prices[i]);
        }
        return sum;
    }

    /// compute value of an asset with an amount in 10**18 and price as 10**18
    function computeValue(uint amount, uint price) internal pure returns (uint) {
        if (amount == 0 || price == 0) { return 0; }
        return amount * price;
    }

    /// compute portion of an asset to return based on shares burnt
    function computePayable(address shares, uint amountIn, address asset) internal pure returns (uint) {
        require(shares != address(0), "Address is zero");
        require(amountIn != 0, "Value is zero");
        require(tokenOut != address(0), "Address is zero");
        IPoolToken sharesInterface = IPoolToken(shares);
        IToken assetInterface = IToken(asset);
        /// assume shares are as 10**18
        uint supply = sharesInterface.totalSupply();
        require(supply != 0, "Value is zero");
        /// determine % ownership of the balance in the vault
        uint ownership = (amountIn * 10000) / supply;
        /// convert balance from asset native decimals to 10**18
        uint balance = assetInterface.balanceOf(address(this));
        balance = balance.computeAsStandardValue(assetInterface.decimals());
        return (balance * ownership) / 10000;
    }

    
}