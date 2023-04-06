// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts\node_modules@openzeppelincontracts\tokenERC20ERC20.sol";
import "smart_contracts\libraries\Vesting.sol";

contract ModelERC20 is ERC20 {
    bool isPausable;
    bool isPaused;
    bool isMintable;
    bool isBurnable;
    bool isTransferable;

    mapping(address => uint256) private _

    constructor() override {
        super.constructor();
        isPausable = true;
        isPaused = true;
        isMintable = true;
        isBurnable = true;
        isTransferable = true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require(isPaused != true, "isPaused == true");
        super.approve();
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        require(isPaused != true, "isPaused == true");
        super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(isPaused != true, "isPaused == true");
        super.decreaseAllowance(spender, subtractedValue);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(isPaused != true, "isPaused == true");
        require(isTransferable != false, "isTransferable == false");
        super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        require(isPaused != true, "isPaused == true");
        require(isTransferable != false, "isTransferable == false");
        super.transferFrom(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(isPaused != true, "isPaused == true");
        require(isMintable != false, "isMintable == false");
        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(isPaused != true, "isPaused == true");
        require(isBurnable != false, "isBurnable == false");
        super._burn(account, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override{
        super._beforeTokenTransfer(from, to, amount)
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._afterTokenTransfer(from, to, amount);
    }

    _mintWithVesting(address account, uint256 amount, uint256 duration) internal virtual {
        super._mint(account, amount);
    }
}
