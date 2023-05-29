// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// openzeppelin imports pausable, ownable
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// openzeppelin imports through github IERC20
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

interface ISafe {}

contract Safe is Pausable, Ownable {

    address[] private contracts;

    constructor() Ownable() {}

    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**18;
    }

    function _deposit() internal payable {}

    function _withdraw(address payable to, uint256 value) internal {
        to.transfer(value);
    }

    function _depositERC20(address contract_, address from, uint256 value) internal {
        (
            bool success
        ) = IERC20(contract_).transferFrom(from, address(this), value);
        require(success);
    }

    function _withdrawERC20(address contract_, address)

    // ... owner commands ...

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function deposit() public payable onlyOwner {
        _deposit();
    }

    function withdraw(address payable to, uint256 value) public {
        _withdraw(to, value);
    }



}