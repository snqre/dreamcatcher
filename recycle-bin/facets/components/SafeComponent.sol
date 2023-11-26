// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";
import "contracts/polygon/diamonds/facets/components/OracleComponent.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";

library SafeComponent {
    using RoleComponent for RoleComponent.Role;
    using OracleComponent for OracleComponent.Oracle;

    struct Safe {
        EnumerableSet.AddressSet _assets;
        uint _maxTypes;
    }

    function assets(Safe storage safe, uint i) internal view returns (address) {
        return safe._assets.at(i);
    }

    function assets(Safe storage safe) internal view returns (address[] memory) {
        return safe._assets.values();
    }

    function assetsLength(Safe storage safe) internal view returns (uint) {
        return safe._assets.length();
    }

    function hasAsset(Safe storage safe, address asset) internal view returns (bool) {
        return safe._assets.contains(asset);
    }

    function maxTypes(Safe storage safe) internal view returns (uint) {
        return safe._maxTypes;
    }

    function deposit(Safe storage safe, RoleComponent.Role storage role, address tokenIn, uint amountIn) internal {
        role.tryAuthenticate();
        IToken tkn = IToken(tokenIn);
        tkn.transferFrom(msg.sender, address(this), amountIn);
        /// ignores duplicate assets
        aknowledgeAsset(safe, role, tokenIn);
    }

    function deposit(Safe storage safe, RoleComponent.Role storage role) internal {
        role.tryAuthenticate();
        /// ignores duplicate assets
        aknowledgeAsset(safe, role, address(0));
    }

    /// withdraw token to address | remove token from assets if balance is zero
    function withdraw(Safe storage safe, RoleComponent.Role storage role, address to, address tokenOut, uint amountOut) internal {
        role.tryAuthenticate();
        IToken tkn = IToken(tokenOut);
        tkn.transfer(to, amountOut);
        if (tkn.balanceOf(address(this)) == 0) {
            forgetAsset(safe, role, tokenOut);
        }
    }

    /// withdraw eth to an address | remove eth from assets if balance is zero
    function withdraw(Safe storage safe, RoleComponent.Role storage role, address to, uint amountOut) internal {
        role.tryAuthenticate();
        payable(to).transfer(to, amountOut);
        if (tkn.balanceOf(address(this)) == 0) {
            forgetAsset(safe, role, address(0));
        }
    }

    function setMaxTypes(Safe storage safe, RoleComponent.Role storage role, uint value) internal {
        role.tryAuthenticate();
        safe._maxTypes = value;
    }

    function aknowledgeAsset(Safe storage safe, RoleComponent.Role storage role, address asset) internal {
        role.tryAuthenticate();
        require(assetsLength(safe) + 1 <= maxTypes(safe), "SafeComponent: max types reached");
        safe._assets.add(asset);
    }

    function forgetAsset(Safe storage safe, RoleComponent.Role storage role, address asset) internal {
        role.tryAuthenticate();
        safe._assets.remove(asset);
    }
}