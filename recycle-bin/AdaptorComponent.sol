// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "contracts/polygon/libraries/OurMathLib.sol";

interface IERC20Interface is IERC20, IERC20Metadata, IERC20Permit {}

library AdaptorComponent {
    using OurMathLib for uint;

    error AdaptorERC20NameNotCompatible();
    error AdaptorERC20SymbolNotCompatible();
    error AdaptorERC20DecimalsNotCompatible();
    error AdaptorERC20HasNotBeenReleased();
    error AdaptorERC20HasNotBeenWrapped();

    struct Adaptor {
        address _token;
    }

    function token(Adaptor storage adaptor) internal view returns (address) {
        return adaptor._token;
    }

    function tokenInterface(Adaptor storage adaptor) internal view returns (IERC20Interface) {
        return IERC20Interface(adaptor);
    }

    function wrap(Adaptor storage adaptor, address token) internal returns (bool) {
        return _wrap(adaptor, token);
    }

    function transfer(Adaptor storage adaptor, address to, uint amount) internal returns (bool) {
        _transfer(adaptor, to, amount);
        return true;
    }

    function transferFrom(Adaptor storage adaptor, address from, address to, uint amount) internal returns (bool) {
        _transferFrom(adaptor, from, to, amount);
        return true;
    }

    function release(Adaptor storage adaptor) internal returns (bool) {
        return _release(adaptor);
    }

    function _wrap(Adaptor storage adaptor, address token) private returns (bool) {
        _requireERC20IsReleased(adaptor);
        _requireERC20IsCompatible(adaptor);
        adaptor._token = token;
        return true;
    }

    function _release(Adaptor storage adaptor) private returns (bool) {
        adaptor._token = address(0);
        return true;
    }

    function _transfer(Adaptor storage adaptor, address to, uint amount) private returns (bool) {
        _requireERC20IsWrapped(adaptor);
        /// take 10**18 input and turn it into native
        amount = amount.computeAsNativeValue(tokenInterface().decimals());
        IERC20 tkn = IERC20(token(adaptor));
        SafeERC20.safeTransfer(tkn, to, amount);
        return true;
    }

    function _transferFrom(Adaptor storage adaptor, address from, address to, uint amount) private returns (bool) {
        _requireERC20IsWrapped(adaptor);
        /// take 10**18 input and turn it into native
        amount = amount.computeAsNativeValue(tokenInterface().decimals());
        IERC20 tkn = IERC20(token(adaptor));
        SafeERC20.safeTransferFrom(tkn, from, to, amount);
        return true;
    }

    function _requireERC20IsReleased(Adaptor storage adaptor) private view returns (bool) {
        if (adaptor._token != address(0)) {
            revert AdaptorERC20HasNotBeenReleased();
        }
        return true;
    }

    function _requireERC20IsWrapped(Adaptor storage adaptor) private view returns (bool) {
        if (adaptor._token == address(0)) {
            revert AdaptorERC20HasNotBeenWrapped();
        }
        return true;
    }

    function _requireERC20IsCompatible(Adaptor storage adaptor) private view returns (bool) {
        _requireERC20HasCompatibleAllowanceFunction(adaptor);
        _requireERC20HasCompatibleBalanceOfFunction(adaptor);
        _requireERC20HasCompatibleDecimalsFunction(adaptor);
        _requireERC20HasCompatibleNameFunction(adaptor);
        _requireERC20HasCompatibleSymbolFunction(adaptor);
        _requireERC20HasCompatibleTotalSupplyFunction(adaptor);
        _requireERC20HasCompatibleTransferFromFunction(adaptor);
        _requireERC20HasCompatibleTransferFunction(adaptor);
        return true;
    }

    function _requireERC20HasCompatibleTransferFromFunction(Adaptor storage adaptor) private view returns (bool) {
        SafeERC20.safeTransferFrom(IERC20(token(adaptor)), msg.sender, address(this), 0);
        return true;
    }

    function _requireERC20HasCompatibleTransferFunction(Adaptor storage adaptor) private view returns (bool) {
        SafeERC20.safeTransfer(IERC20(token(adaptor)), msg.sender, 0);
        return true;
    }

    function _requireERC20HasCompatibleAllowanceFunction(Adaptor storage adaptor) private view returns (bool) {
        tokenInterface().allowance(address(this), msg.sender);
        return true;
    }

    function _requireERC20HasCompatibleBalanceOfFunction(Adaptor storage adaptor) private view returns (bool) {
        tokenInterface().balanceOf(address(this));
        return true;
    }

    function _requireERC20HasCompatibleTotalSupplyFunction(Adaptor storage adaptor) private view returns (bool) {
        tokenInterface().totalSupply();
        return true;
    }

    function _requireERC20HasCompatibleDecimalsFunction(Adaptor storage adaptor) private view returns (bool) {
        if (tokenInterface().decimals() > 18) {
            revert AdaptorERC20DecimalsNotCompatible();
        }
        return true;
    }

    function _requireERC20HasCompatibleSymbolFunction(Adaptor storage adaptor) private view returns (bool) {
        if (bytes(tokenInterface().symbol()).length == 0) {
            revert AdaptorERC20SymbolNotCompatible();
        }
        return true;
    }

    function _requireERC20HasCompatibleNameFunction(Adaptor storage adaptor) private view returns (bool) {
        if (bytes(tokenInterface().name()).length == 0) {
            revert AdaptorERC20NameNotCompatible();
        }
        return true;
    }
}