// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/State.sol";

import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";

/**
* @dev Stand alone and no proxy vault for the closed beta Solstice.
*
* _string: "name"
* _address: "manager"
* _addressSet: "depositors"
 */
contract SolsticeVault is State {

    using EnumerableSet for EnumerableSet.AddressSet;
    
    



    /** Public View. */

    function name() public view returns (string memory) {

        return _string[keccak256(abi.encode("name"))];
    }

    function manager() public view returns (address) {

        return _address[keccak256(abi.encode("manager"))];
    }

    function depositors() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("depositors"))];
    }

    /**
    * @dev Positions is a set of token contracts that have been
    *      interfacted with. These are stored in a set so
    *      when each position can be accounted for during
    *      financial and statistic calculations.
     */
    function positions() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("positions"))];
    }

    /**
    * @dev Set of token contracts which are allowed to enter the
    *      vault as deposits.
     */
    function allowedIn() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("allowedIn"))];
    }

    /**
    * @dev Set of token contracts which are allowed to leave the
    *      vault as withdrawals.
    *
    * NOTE If there is not enough value to honor the withdrawal
    *      in the selected token contracts, the client will
    *      be paid in kind even if the contract is not allowed
    *      out.
     */
    function allowedOut() public view returns (address[] memory) {

        return _addressSet[keccak256(abi.encode("allowedOut"))];
    }

    /**
    * @dev When a deposit occurs the allowed in contracts will
    *      stop any other token contracts from entering the vault
    *      through deposits. ReceiveIn if not zero, will swap all
    *      received tokens automatically to a single token ie. USDT.
     */
    function receiveIn() public view returns (address) {

        return _address[keccak256(abi.encode("receiveIn"))];
    }

    /**
    * @dev Just like receiveIn will determine wether to swap outgoing
    *      tokens for a single return token on withdrawal.
     */
    function receiveOut() public view returns (address) {

        return _address[keccak256(abi.encode("receiveOut"))];
    }

    function netAssetValue() public view returns (uint256) {

    }

    function navps() public view returns (uint256);

    /** Vault token address. */
    function erc20() public view returns (address);

    /** Public. */

    

    /** Internal. */

    function setName(string calldata name) internal {

        _string[keccak256(abi.encode("name"))] = name;
    }

    function setManager(address account) internal {

        _address[keccak256(abi.encode("manager"))] = account;
    }

    function _addDepositor(address account) internal {

        _addressSet[keccak256(abi.encode("depositors"))].add(account);
    }

    function _removeDepositor(address account) internal {

        _addressSet[keccak256(abi.encode("depositors"))].remove(account);
    }

    function _addPosition(address token) internal {

        _addressSet[keccak256(abi.encode("positions"))].add(token);
    }

    function _removePosition(address token) internal {

        _addressSet[keccak256(abi.encode("positions"))].remove(token);
    }
}