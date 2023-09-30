// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/libraries/__Finance.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

import "contracts/polygon/interfaces/IERC20Mintable.sol";

import "contracts/polygon/ERC20Mintable.sol";

import "contracts/polygon/external/openzeppelin/access/Ownable.sol";

import "contracts/polygon/external/openzeppelin/security/Pausable.sol";

import "contracts/polygon/external/openzeppelin/security/ReentrancyGuard.sol";

import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

contract SolsticeVault is Ownable, Pausable, ReentrancyGuard {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct UniswapV2 {
        address router;
        address factory;
        string name;
    }

    UniswapV2[] private _uniswapV2s;

    IERC20Mintable private _shares;

    EnumerableSet.AddressSet private _allowedIn;

    EnumerableSet.AddressSet private _allowedOut;

    EnumerableSet.AddressSet private _interactedWith;

    /** Constructor. */

    constructor(string memory name, string memory symbol) {

        _shares = IERC20Mintable(address(new ERC20Mintable({name: name, symbol: symbol, vault: address(this)})));
    }

    /** Public View. */

    function name() public view returns (string memory) {

        return _shares.name();
    }

    function symbol() public view returns (string memory) {

        return _shares.symbol();
    }

    function decimals() public view returns (uint8) {

        return _shares.decimals();
    }

    function totalSupply() public view returns (uint256) {

        return _shares.totalSupply();
    }

    function totalValue() public view returns (uint256) {

        uint256 totalValue;

        for (uint256 i = 0; i < _interactedWith.length; i++) {

            
        }

        __Finance.netAssetValue(factories(), tokens, denominator);
    }

    function factories() public view returns (address[] memory) {

        uint256 len = _uniswapV2s.length;

        require(len >= 1, "len == 0");

        address[] memory factories;

        factories = new address[](len);

        for (uint256 i = 0; i < len; i++) {

            factories[i] = _uniswapV2s[i].factory;
        }

        return factories;
    }

    function value(address token, uint256 amount) public view returns (uint256) {

        __Finance.meanPrice(factories, tokenA, tokenB, amount);
    }

    /** Public. */

    function importUniswapV2(string memory name, address router, address factory) public onlyOwner() whenNotPaused() returns (bool) {
        
        UniswapV2 uniswapV2 = UniswapV2({router: router, factory: factory, name: name});
        
        _uniswapV2s.push(uniswapV2);
        
        return true;
    }
}