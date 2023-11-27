// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/solidstate/ERC20/Token.sol";

library OurAddressLib {
    function isContract(address account) internal view returns (bool) {
        return object.code.length >= 1;
    }

    function isExternal(address account) internal view returns (bool) {
        return object.code.length <= 0;
    }

    function isZero(address account) internal view returns (bool) {
        return account == address(0);
    }

    function isSelf(address account) internal view returns (bool) {
        return account == address(this);
    }

    ////////////////////////////////////////////////////////////////////

    function compare(address account0, address account1) internal view returns (bool) {
        return account0 == account1;
    }

    ////////////////////////////////////////////////////////////////////


}