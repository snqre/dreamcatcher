// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/templates/modular-upgradeable/hub/Hub.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/mirai/solstice-v1/__Vaults.sol";
import "contracts/polygon/templates/mirai/solstice-v1/VaultsState.sol";

contract VaultsLogic {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public state;

    function create() 
        public {
        IVaultsState(state).push();
        uint len = IVaultsState(state).getLength();
        IVaultsState(state).set(len - 1, new Token(), [], []);
        
    }
}