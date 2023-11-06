// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract GateLite is StorageLite {

    event SourceCode(bytes indexed sourceCode);

    function emitSourceCode(bytes calldata newSourceCode) external {
        _emitSourceCode(newSourceCode);
    }

    function _emitSourceCode(bytes memory newSourceCode) internal {
        emit SourceCode(newSourceCode);
    }
}