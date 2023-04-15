// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RESTARTED, I THINK I CAN DO IT BETTER
// WE CANT USE OPENZEPPELIN BECAUSE THEY DONT ALLOW US TO FLEXIBLY EDIT
// BUT WILL BE BORROWING SOME OF THEIR BASE LINE FRAMEWORKS

/// @notice Token Contract
/// @dev It does token stuff and hurts my brain
/// @author Marco

inteface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function totalSupply() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}

library LibToken {
    // Its more gas efficient to store stings as bytes and convert them to string only when needed
    function getBytesAsString(bytes _bytes) internal view returns (string memory) {
        return string(_bytes) // converts bytes to string
    }

    function setStringAsBytes(string memory _string) internal view returns (bytes) {
        return bytes(_string);
    }

    // apparently openzeppelin thinks we should not access msg.sender directly so we'll do it this way
    function msgSender() internal view returns (address) {
        return msg.sender;
    }

    function msgData() internal view returns (bytes calldata) {
        return msg.data;
    }

}

contract Token is IERC20 {
    // var_ :: because function names conflict with ERC20 get functions
    bytes private name_;
    bytes private symbol_;
    uint256 private totalSupply_;
    mapping(address=>uint256) private balances;
    mapping(address=>mapping(address=>uint256)) private allowances;

    constructor() {
        name_ = LibToken.setStringAsBytes("Dreamcatcher");
        symbol_ = LibToken.setStringAsBytes("DREAM");
        totalSupply_ = 0;
    }

    function name() public view returns (string memory) {return LibToken.getBytesAsString(name_);}
    function symbol() public view returns (string memory) {return LibToken.getBytesAsString(symbol_);}
    function decimals() public view returns (uint8) {return 18;}
    function totalSupply() public view returns (uint256) {return totalSupply_;}
    function balanceOf(address _owner) public view returns (uint256) {return balances[_owner];}
    function transfer(address _to, uint256 _amount) public returns (bool) {
        address owner = LibToken.msgSender();
        require(owner != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");

        

        return true;
    }

    function beforeTokenTransfer(address _from, address _to, uint256 _amount) internal {

    }

    function afterTokenTransfer(address _from, address _to, uint256 _amount) internal {

    }

}