// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;
import "deps/openzeppelin/access/Ownable.sol";
import "deps/openzeppelin/token/ERC20/IERC20.sol";
import "deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IVault {
    /// OWNER COMMANDS
    function transfer(
        address target,
        address to,
        uint amount
    ) public
    returns (bool);

    function transferFrom(
        address target,
        address from,
        uint amount
    ) public
    returns (bool);
}

contract Vault is IVault, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor() Ownable() { _transferOwnership(msg.sender); }

    function _transfer(
        address target,
        address to,
        uint amount
    ) internal virtual
    returns (bool) {
        /// transfer token.
        bool success = IERC20(target).transfer(
            to, 
            amount
        );

        require(
            success,
            "Unable to make transfer."
        );

        return true;
    }

    function _transferFrom(
        address target,
        address from,
        uint amount
    ) internal virtual
    returns (bool) {
        /// request tokens from account.
        bool success = IERC20(target).transferFrom(
            from,
            address(this), 
            amount
        );

        require(
            success,
            "Unable to receive tokens."
        );

        return true;
    }

    /// OWNER COMMANDS
    function transfer(
        address target,
        address to,
        uint amount
    ) public onlyOwner
    returns (bool) {
        return _transfer(
            target, 
            to, 
            amount
        );
    }

    function transferFrom(
        address target,
        address from,
        uint amount
    ) public onlyOwner
    returns (bool) {
        return _transferFrom(
            target, 
            from, 
            amount
        );
    }

    fallback() public payable {}
}