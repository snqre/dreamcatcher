// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

contract SetVault is {
    IERC20 public token;

    mapping(address => uint256) public contribution;

    constructor(address nativeToken, address owner) payable
    Ownable(owner) {
        token = IERC20(nativeToken);
        contribute();
    }

    function _amountToMint(uint256 v, uint256 s, uint256 b)
    internal pure
    returns (uint256) {
        require(v >= Utils.convertToWei(1), "PoolVault: Insufficient value (v).");
        require(s >= Utils.convertToWei(1), "PoolVault: Insufficient value (s).");
        require(b >= Utils.convertToWei(1), "PoolVault: Insufficient value (b).");

        return ((v * s) / b);
    }

    function _amountToSend(uint256 v, uint256 s, uint256 b)
    internal pure
    returns (uint256) {
        require(v >= Utils.convertToWei(1), "PoolVault: Insufficient value (v).");
        require(s >= Utils.convertToWei(1), "PoolVault: Insufficient value (s).");
        require(b >= Utils.convertToWei(1), "PoolVault: Insufficient value (b).");

        return ((v * b) / s);
    }

    function contribute()
    public virtual payable
    returns (bool) {
        uint256 v = msg.value;
        uint256 s = token.totalSupply();
        uint256 b = address(this).balance;
    
        contribution[msg.sender] += msg.value;

        address to = msg.sender;
        token.mint(to, _amountToMint(v, s, b));
        return true;
    }

    function withdraw(uint256 amount)
    external virtual
    returns (bool) {
        uint256 v = msg.value;
        uint256 s = token.totalSupply();
        uint256 b = address(this).balance;

        contribution[msg.sender] -= msg.value;

        token.transferFrom(msg.sender, address(this), amount);
        token.burn(amount);
        
        address payable to = payable(msg.sender);
        to.transfer(_amountToSend(v, s, b));
        return true;
    }
}