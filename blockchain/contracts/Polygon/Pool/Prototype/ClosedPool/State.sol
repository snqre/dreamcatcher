// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract State {
    address logic;
    address creator;
    address governor;

    uint256 duration;
    uint256 minDuration;
    uint256 maxDuration;
    uint256 start;
    uint256 end;
    uint256 required;
    bool whitelisted;
    bool transferable;
    uint256 target;
    uint256 finish;

    mapping(address => bool) private whitelist;

    constructor(
        address _logic,         // logic contract
        address _creator,       // creator of the pool
        address _governor,      // dreamcatcher governor contract
        string memory _name,    // name of the pool
        uint256 _duration,      // duration of the initial funding round
        uint256 _required,      // amount of matic required to pass the pool if applicable
        bool _whitelisted,      // only whitelisted domains can participate
        bool _transferable,     // can be transfered to external domains note you cant transfer until the funding round is officially over
        uint256 _target,        // target amount the pool wants to reach if applicable
        uint256 _finish         // target date the pool will end if applicable
    ) {
        minDuration = 0;
        maxDuration = 0;

        require(_logic != address(0));
        require(_creator != address(0));
        require(_governor != address(0));
        require(_duration >= 0);
        require(_required >= 0);
        require(_target >= 0);
        require(_finish >= 0);

        if (_minDuration != 0) {
            require(_duration >= _minDuration);
            require(_minDuration <= _maxDuration);
        }

        if (_maxDuration != 0) {
            require(_duration <= _maxDuration);
        }

        uint256 _now     = block.timestamp;
        duration         = _duration;
        start            = _now;
        end              = _now + _duration;
        required         = _required;
        whitelisted      = _whitelisted;
        transferable     = _transferable;
        target           = _target;
        finish           = _finish;

        logic            = _logic;
        creator          = _creator;
        governor         = _governor;
    }

    function setWhitelist(address _domain, bool _state) public returns (bool) {
        require(
            msg.sender == logic ||
            msg.sender == creator
        );
        require(_domain != address(0));
        whitelist[_domain] = _state;
        return true;
    }

    function getWhitelist(address _domain) public view returns (bool) {return whitelist[_domain];}
}