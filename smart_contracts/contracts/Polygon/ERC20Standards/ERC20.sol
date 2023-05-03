// SPDX-License-Identifier: MIT
/**
In this version only admin can mint and burnFrom
 */

pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PoolToken is ERC20Burnable {
    address private owner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        require(_initialSupply >= 1 * 10**18, "PoolToken: _initialSupply < 1 * 10**18");
        owner = msg.sender;
        mint(owner, _initialSupply);
    }

    function name() public view override returns (string memory) {super.name();}
    function symbol() public view override returns (string memory) {super.symbol();}
    function decimals() public view override returns (uint8) {super.decimals();}
    function totalSupply() public view override returns (uint256) {super.totalSupply();}
    function balanceOf(address _account) public view override returns (uint256) {super.balanceOf(_account);}
    function transfer(address _to, uint256 _amount) public override returns (bool) {super.transfer(_to, _amount);}
    function allowance(address _owner, address _spender) public view override returns (uint256) {super.allowance;}
    function approve(address _spender, uint256 _amount) public override returns (bool) {super.approve;}
    function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool) {super.transferFrom(_from, _to, _amount);}
    function increaseAllowance(address _spender, uint256 _amount) public override returns (bool) {super.increaseAllowance;}
    function decreaseAllowance(address _spender, uint256 _amount) public override returns (bool) {super.decreaseAllowance;}
    function mint(address _to, uint256 _amount) public {
        require(msg.sender == owner, "PoolToken: msg.sender != owner");
        super._mint(_to, _amount);
    }

    function burn(uint256 _amount) public override {super.burn(_amount);}
    function burnFrom(address _from, uint256 _amount) public override admin {
        require(msg.sender == owner, "PoolToken: msg.sender != owner");
        super.burnFrom(_from, _amount);
    }
}
