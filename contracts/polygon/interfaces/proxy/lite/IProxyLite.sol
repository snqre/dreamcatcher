// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/abstracts/utils/lite/IConfigurableLite.sol";

interface IProxyLite is IConfigurableLite {
    function implementation() external view returns (address);

    function configure(address newImplementation) external;
}