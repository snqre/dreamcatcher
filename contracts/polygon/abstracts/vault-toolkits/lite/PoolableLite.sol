// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract PoolableLite is StorageLite {

    function ____mintFee() internal pure virtual returns (uint) {
        
    }

    function _amountToMint() internal view virtual returns (uint) {

    }
}