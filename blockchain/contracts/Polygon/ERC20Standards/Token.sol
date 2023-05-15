// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address private owner;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        owner = msg.sender;
    }

    function mint(address _to, uint256 _value) public returns (bool) {
        require(
            msg.sender == owner &&
            _to != address(0) &&
            _value >= 0,
            "Token: msg.sender != owner || _to == address(0) || _value < 0"
        );
        _mint(_to, _value * 10**18);
        return true;
    }

    function burn(address _from, uint256 _value) public returns (bool) {
        require(
            msg.sender == owner &&
            _from != address(0) &&
            _value >= 0,
            "Token: msg.sender != owner || _from == address(0) || _value < 0"
        );
        _burn(_from, _value * 10**18);
        
        return true;
    }
}