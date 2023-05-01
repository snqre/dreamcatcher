pragma solidity ^0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address _to, uint256 _value) external returns (bool);

    function withdraw(uint256) external;
}
