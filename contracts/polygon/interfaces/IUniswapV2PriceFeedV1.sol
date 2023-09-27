// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/interfaces/IProxyStateOwnable.sol";

interface IUniswapV2PriceFeedV1 is IProxyStateOwnable {

    function getMetadata(address factory, address tokenA, address tokenB) external view
    returns (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint256,
        uint256
    );

    function isSameOrder(address factory, address tokenA, address tokenB) external view returns (uint256);

    function getPrice(address factory, address tokenA, address tokenB, uint256 amount) external view returns (uint256, uint256);
}