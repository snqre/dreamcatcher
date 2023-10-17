// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/interfaces/IUniswapV2Factory.sol";
import "contracts/polygon/interfaces/IUniswapV2Pair.sol";
import "contracts/polygon/interfaces/IUniswapV2Router02.sol";

contract Oracle {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _factories;

    enum Order { SAME, REVERSE, UNKNOWN }

    struct Pair {
        address pair;
        address tokenA;
        address tokenB;
        string nameA;
        string nameB;
        string symbolA;
        string symbolB;
        uint8 decimalsA;
        uint8 decimalsB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 valueA;
        uint256 valueB;
        uint256 lastTimestamp;
        Order order;
    }

    function factories() public view returns (address[] memory) {
        return _factories.values();
    }

    function factory(uint256 index) public view returns (address) {
        return _factories.at(index);
    }

    function interfaceFactory(uint256 index) public view returns (IUniswapV2Factory memory) {
        return IUniswapV2Factory(factory(index));
    }

    function factoriesLength() public view returns (uint256) {
        return _factories.length();
    }

    function pairs(address tokenA, address tokenB) public view returns (address[] memory) {
        address[] memory pairs;
        pairs = new address[](factoriesLength());
        for (uint256 i = 0; i < factoriesLength(); i++) {
            IUniswapV2Factory interface_ = interfaceFactory(i);
            pairs[i] = interface_.getPair(tokenA, tokenB);
        }
        return pairs;
    }


}