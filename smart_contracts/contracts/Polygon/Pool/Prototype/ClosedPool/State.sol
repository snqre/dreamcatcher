// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

contract State {
    mapping(address => uint256) internal contribution;
    mapping(address => bool) internal isManager;
    mapping(address => bool) internal isAdmin;
    mapping(address => bool) internal whitelisted;

    struct Toggles {
        bool extensions; // allow matic to be transfered to external contracts
        bool whitelist;  // only whitelisted addresses can contribute to the pool
    }

    Toggles internal toggles;

    struct InitialFunding {
        uint256 start;
        uint256 duration;
        uint256 required;   // wei **if this is not met, anyone who contributed will be entitled to get their matic back
    }

    InitialFunding internal initialFunding;

    modifier manager() {
        require(isManager[msg.sender], "State: msg.sender != manager");
        _;
    }

    modifier admin() {
        require(isAdmin[msg.sender], "State: msg.sender != admin");
        _;
    }

    constructor(address _admin) {
        isAdmin[address(this)] = true;
        isAdmin[_admin] = true;
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

    function setWhitelist(address _account, bool _state) public admin returns (bool) {
        whitelisted[_account] = _state;
        return true;
    }

    function whitelistedOf(address _account) public returns (bool) {
        return whitelisted[_account];
    }

    function setToggles(
        bool _extensions,
        bool _whitelist
    ) public admin returns (bool) {
        toggles.extensions = _extensions;
        toggles.whitelist = _whitelist;
    }

    function getToggles() public returns (
        bool,
        bool
    ) {
        return (
            toggles.extensions,
            toggles.whitelist
        );
    }

    function setInitialFunding(
        uint256 _start,
        uint256 _duration,
        uint256 _required
    ) public admin returns (bool) {
        initialFunding.start = _start;
        initialFunding.duration = _duration;
        initialFunding.required = _required;
    }
    
    function getInitialFunding() public returns (
        uint256,
        uint256,
        uint256
    ) {
        return (
            initialFunding.start,
            initialFunding.duration,
            initialFunding.required
        );
    }
}
