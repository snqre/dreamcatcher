// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

contract State {
    mapping(address => uint256) internal contribution;
    mapping(address => bool) internal isManager;
    mapping(address => bool) internal isAdmin;
    modifier manager() {
        require(isManager[msg.sender], "State: msg.sender != manager");
    }
    modifier admin() {
        require(isAdmin[msg.sender], "State: msg.sender != admin");
    }

    constructor(address _admin) {
        isAdmin[address(this)] = true;
        setAdmin(_admin, true);
    }

    function setAdmin(address _account, bool _state)
        public
        admin
        returns (bool)
    {
        isAdmin[_account] = _state;
        return true;
    }

    function adminOf(address _account) public returns (bool) {
        return isAdmin[_account];
    }

    function setManager(address _account, bool _state)
        public
        admin
        returns (bool)
    {
        isManager[_account] = _state;
        return true;
    }

    function managerOf(address _account) public returns (bool) {
        return isManager[_account];
    }

    function setContribution(address _account, uint256 _amount)
        public
        admin
        returns (bool)
    {
        contribution[_account] = _amount;
        return true;
    }

    function contributionOf(address _account) public returns (uint256) {
        return contribution[_account];
    }
}
