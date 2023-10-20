// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/abstracts/utils/lite/IInitializableLite.sol";

interface IDefaultImplementationLite is IInitializableLite {
    event Upgraded(address indexed previousImplementation, address indexed newImplementation);
}
