// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/DRCs/DRC00.sol";

/// DRC10: Oracle Adaptor v1.0.0
interface DRC10 is DRC00 {
    function price(
        address tokenA,
        address tokenB
    )
    external view
    returns (
        uint price,
        uint lastTimestamp
    );
    

}