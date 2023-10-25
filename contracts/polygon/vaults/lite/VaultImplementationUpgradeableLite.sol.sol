// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/proxy/lite/DefaultImplementationLite.sol";
import "contracts/polygon/abstracts/vault-toolkits/lite/WalletLite.sol";
import "contracts/polygon/abstracts/vault-toolkits/lite/TrackedUsedLite.sol";
import "contracts/polygon/abstracts/vault-toolkits/lite/SwapperLite.sol";
import "contracts/polygon/abstracts/access-control/lite/OwnableLite.sol";
import "contracts/polygon/abstracts/security/lite/ReentrancyGuardLite.sol";
import "contracts/polygon/abstracts/security/lite/PausableLite.sol";

contract VaultImplementationUpgradeableLite is DefaultImplementationLite, OwnableLite, Walletlite, TrackedUsedLite, SwapperLite, ReentrancyGuardLite, PausableLite {

    function totalAssets() public view virtual returns (uint) {
        uint sum;
        for (uint i = 0; i < size() + 1; i++) {
            if (tracked(i) != address(0)) {
                uint balance = balanceERC20(tracked(i));
                uint price;
                balance *= price;
                sum += balance;
            }   
        }
    }

    function initialize() public virtual {
        _initialize();
    }

    function upgrade(address newImplementation) public virtual {
        _whenPaused();
        _onlyOwner();
        _upgrade(newImplementation);
    }

    function pause() public virtual {
        _onlyOwner();
        _pause();
    }

    function unpause() public virtual {
        _onlyOwner();
        _unpause();
    }

    function depositERC20(address tokenIn, uint amountIn) public nonReentrant() virtual {
        _whenNotPaused();
        _depositERC20(tokenIn, amountIn);
    }

    function withdrawERC20(address to, address tokenOut, uint amountOut) public nonReentrant() virtual {
        _whenNotPaused();
        _onlyOwner();
        _withdrawERC20(to, tokenOut, amountOut);
    }

    function depositMATIC() public payable nonReentrant() virtual {
        _whenNotPaused();
        _depositMATIC();
    }

    function withdrawMATIC(address to, uint amountOut) public nonReentrant() virtual {
        _whenNotPaused();
        _onlyOwner();
        _withdrawMATIC(to, amountOut);
    }

    function setSize(uint newSize) public nonReentrant() virtual {
        _whenNotPaused();
        _onlyOwner();
        _setSize(newSize);
    }

    function _initialize() internal virtual override {
        InitializableLite._initialize();
        OwnableLite._initialize(_msgSender());
        TrackedUsedLite._initialize(200);
    }

    function _depositERC20(address tokenIn, uint amountIn) internal virtual {
        super._depositERC20(tokenIn, amountIn);
        _addTracked(tokenIn);
    }

    function _withdrawERC20(address to, address tokenOut, uint amountOut) internal virtual {
        super._withdrawERC20(to, tokenOut, amountOut);
        _subTracked(tokenOut);
    }

    function _addTracked(address token) internal virtual override {
        if (balanceERC20(token) != 0) {
            super._addTracked(token);
        }
    }

    function _subTracked(address token) internal virtual override {
        if (balanceERC20(token) == 0) {
            super._subTracked(token);
        }
    }
}