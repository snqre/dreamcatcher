// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/libraries/__Finance.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
* => Depsit => Management => Withdrawal
*
*
 */
contract SolsticeVault {

    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public minDeposit;
    uint256 public maxDeposit;

    uint256 public minWithdrawal;
    uint256 public maxWithdrawal;

    bool public live;

    EnumerableSet.AddressSet private _allowedIn;

    function _onlyLive() internal view {

        require(live, "!live");
    }


}