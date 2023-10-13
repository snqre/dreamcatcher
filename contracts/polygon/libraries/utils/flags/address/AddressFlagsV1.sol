// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Factory.sol";
import "contracts/polygon/interfaces/token/dream/IDream.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Pair.sol";
import "contracts/polygon/interfaces/uniswap/uniswap-v2/IUniswapV2Router01.sol";

/**
 * @title AddressFlagsV1 Library
 * @dev A library providing utility functions for handling common address-related checks and interactions.
 */
library AddressFlagsV1 {

    /**
    * @dev Error thrown when an operation expects an address to be zero, but it is a non-zero address.
    */
    error IsZeroAddress();

    /**
    * @dev Error thrown when an operation expects an address to be non-zero, but it is a zero address.
    */
    error IsNotZeroAddress();

    /**
    * @dev Error thrown when an address is expected to be a certain value.
    * @param account The address that is expected.
    */
    error IsAddress(address account);

    /**
    * @dev Error thrown when an address is expected not to be a certain value.
    * @param account The address that is not expected.
    */
    error IsNotAddress(address account);

    /**
    * @notice Pure function to ensure that the input address is equal to a specified account address.
    * @param self The address to be checked.
    * @param account The address to compare against.
    * @return The input address itself if equal to the specified account address.
    * @dev Throws an `IsNotAddress` error if the input address is not equal to the specified account address.
    */
    function onlyAddress(address self, address account) public pure returns (address) {
        if (self != account) { revert IsNotAddress(account); }
        return self;
    }

    /**
    * @notice Pure function to ensure that the input address is not equal to a specified account address.
    * @param self The address to be checked.
    * @param account The address to compare against.
    * @return The input address itself if not equal to the specified account address.
    * @dev Throws an `IsAddress` error if the input address is equal to the specified account address.
    */
    function onlynotAddress(address self, address account) public pure returns (address) {
        if (self == account) { revert IsAddress(account); }
        return self;
    }

    /**
    * @notice Pure function to ensure that the input address is the zero address.
    * @param self The address to be checked.
    * @return The input address itself if it is the zero address.
    * @dev Throws an `IsNotZeroAddress` error if the input address is not the zero address.
    */
    function onlyZeroAddress(address self) public pure returns (address) {
        if (self != address(0)) { revert IsNotZeroAddress(); }
        return self;
    }

    /**
    * @notice Pure function to ensure that the input address is not the zero address.
    * @param self The address to be checked.
    * @return The input address itself if not the zero address.
    * @dev Throws an `IsZeroAddress` error if the input address is the zero address.
    */
    function onlynotZeroAddress(address self) public pure returns (address) {
        if (self == address(0)) { revert IsZeroAddress(); }
        return self;
    }

    /**
    * @notice Checks if the given address matches the specified account address.
    * @param self The address to be checked.
    * @param account The address to compare against.
    * @return True if the input address is equal to the specified account address, false otherwise.
    */
    function isMatch(address self, address account) public pure returns (bool) {
        return self == account;
    }

    /**
    * @notice View function to interact with specific methods of the ERC20 contract.
    * @param self The address of the ERC20 contract.
    * @return The input address itself after performing various read-only operations.
    */
    function onlyERC20(address self) public view returns (address) {
        IERC20Metadata erc20 = IERC20Metadata(self);
        erc20.name();
        erc20.symbol();
        erc20.decimals();
        erc20.totalSupply();
        erc20.balanceOf(address(this));
        erc20.allowance(msg.sender, address(this));
        return self;
    }

    /**
    * @notice View function to interact with specific methods of the Governance ERC20 contract.
    * @param self The address of the Governance ERC20 contract.
    * @return The input address itself after performing various read-only operations.
    */
    function onlyGovernanceERC20(address self) public view returns (address) {
        IDream erc20 = IDream(self);
        onlyERC20(self);
        erc20.getCurrentSnapshotId();
        return self;
    }

    /**
    * @notice View function to interact with specific methods of the UniswapV2Factory contract.
    * @param self The address of the UniswapV2Factory contract.
    * @return The input address itself after performing various read-only operations.
    */
    function onlyUniswapV2Factory(address self) public view returns (address) {
        IUniswapV2Factory v2 = IUniswapV2Factory(self);
        v2.feeTo();
        v2.feeToSetter();
        v2.allPairs(0);
        v2.allPairsLength();
        return self;
    }

    /**
    * @notice View function to interact with specific methods of the UniswapV2Pair contract.
    * @param self The address of the UniswapV2Pair contract.
    * @return The input address itself after performing various read-only operations.
    */
    function onlyUniswapV2Pair(address self) public view returns (address) {
        IUniswapV2Pair v2 = IUniswapV2Pair(self);
        v2.name();
        v2.symbol();
        v2.decimals();
        v2.totalSupply();
        v2.balanceOf(address(this));
        v2.allowance(msg.sender, address(this));
        v2.DOMAIN_SEPARATOR();
        v2.PERMIT_TYPEHASH();
        v2.MINIMUM_LIQUIDITY();
        v2.factory();
        v2.token0();
        v2.token1();
        v2.getReserves();
        v2.price0CumulativeLast();
        v2.price1CumulativeLast();
        v2.kLast();
        return self;
    }
}