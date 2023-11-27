// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/OurMathLib.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/utils/SafeERC20.sol";

/// does not expect bool
interface {

}

library TokenWrapper {
    using OurMathLib for uint;

    /// checking for unexpected behaviour to protect the protocol
    error ERC20NotCompatible();

    struct WrappedToken {
        address _token;
        bool _locked;
    }

    function token(WrappedToken storage wrappedToken) internal view returns (address) {
        return wrappedToken._token;
    }

    function tokenInterface(WrappedToken storage wrappedToken) internal view returns (IToken) {
        return IToken(token(wrappedToken));
    }

    function requireERC20MetadataCompliance(address token) internal view returns (bool) {
        _nameIsCompatible(token);
        _symbolIsCompatible(token);

        address a;
        address b;
        tokenInterface().name();
        tokenInterface().symbol();
        tokenInterface().decimals();
        tokenInterface().totalSupply();
        tokenInterface().balanceOf(a);
        tokenInterface().allowance(a, b);
        return true;
    }

    function requireERC20Compliance(address token) internal returns (bool) {
        isERC20MetadataCompliant(token);
        tokenInterface().balan
    }

    function wrap(WrappedToken storage wrappedToken, address token) internal returns (bool) {
        if (token.code.length <= 0) { revert TokenWrapperIsNotContract({token: token}); }
        IToken tkn = IToken(token);
        /// compliance checks
        if (bytes(tkn.name()).length == 0) { revert TokenWrapperNameIsZero({name: tkn.name()}); }
        if (bytes(tkn.symbol()).length == 0) { revert TokenWrapperSymbolIsZero({symbol: tkn.symbol()}); }
        if (tkn.totalSupply() == 0) { revert TokenWrapperTotalSupplyIsZero({totalSupply: tkn.totalSupply()}); }
        if (tkn.decimals() > 18) { revert TokenWrapperDecimalsOutOfBounds({value: tkn.decimals(), min: 0, max: 18}); }
        address thisContract;
        address caller;
        /// these calls should fail if the token is not compliant
        tkn.balanceOf({account: thisContract});
        tkn.balanceOf({account: caller});
        tkn.transfer({to: caller, amount: 0});
        tkn.transferFrom({from: caller, to: thisContract, amount: 0});
        tkn.allowance({owner: thisContract, spender: caller});
        tkn.approve({spender: caller, amount: 0});
        /// compliance checks done
        wrappedToken.token = token;
    }

    function transferFrom(WrappedToken storage wrappedToken, address from, address to, uint amount) internal returns (bool) {
        amount = amount.computeAsNativeValue(tokenInterface().decimals());
        bool success = tokenInterface().transferFrom(from, to, amount);
        if ()
    }
    
    function _nameIsCompatible(WrappedToken storage wrappedToken) internal view returns (bool) {
        if (bytes(tokenInterface().name()).length == 0) {
            revert ERC20NotCompatible();
        }
        return true;
    }

    function _symbolIsCompatible(WrappedToken storage wrappedToken) internal view returns (bool) {
        if(bytes(tokenInterface().symbol()).length == 0) {
            revert ERC20NotCompatible();
        }
        return true;
    }
}