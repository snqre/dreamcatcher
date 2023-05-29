// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** openzeppelin imports */
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/** openzeppelin imports through github */
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

interface ISafe {

    event DepositERC20(
        address indexed contract_,
        address indexed from,
        uint256 value
    );

    event WithdrawERC20(
        address indexed contract_,
        address indexed to,
        uint256 value
    );

}

contract Safe is ISafe, Pausable, Ownable {

    address[] public contracts;

    constructor() Ownable() {}

    /** ... private ... */

    /** deposit ERC20 */
    function _depositERC20(address contract_, address from, uint256 value) {
        
        /** request tokens from address */
        bool success = IERC20(contract_).transferFrom(from, address(this), value);

        /** check if transfer was successful */
        require(success, "Safe::_depositERC20: transferFrom failed");

        /** emit event for deposit of ERC20 token */
        emit DepositERC20(
            contract_,
            from,
            value
        );

    }

    /** withdraw ERC20 */
    function _withdrawERC20(address contract_, address to, uint256 value) {

        /** transfer tokens to address */
        bool success = IERC20(contract_).transfer(to, value);

        /** check if transfer was successful */
        require(success, "Safe::_withdrawERC20: transfer failed");

        /** emit event for withdrawal of ERC20 token */
        emit WithdrawERC20(
            contract_,
            to,
            value
        );

    }

    // ... owner commands ...

    function pause() public onlyOwner {

        _pause();

    }

    function unpause() public onlyOwner {
        
        _unpause();

    }

    /** owner command for deposit */
    function depositERC20(address contract_, address from, uint256 value) public onlyOwner returns (bool) {

        /** deposit */
        _depositERC20(contract_, from, value);

        return true;

    }

    /** owner command for withdraw */
    function withdrawERC20(address contract_, address to, uint256 value) public onlyOwner returns (bool) {

        /** withdraw */
        _withdrawERC20(contract_, to, value);

        return true;

    }

}