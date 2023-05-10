// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract State {
    address logic;
    address creator;
    address governor;

    struct Funding {
        uint256 begin;
        uint256 minDuration;
        uint256 maxDuration;
        uint256 duration;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool transferable;
    } Funding private funding;

    // whitelist
    mapping(address => bool) private whitelist;

    constructor(
        uint256 _class,
        address _logic,         // logic contract
        address _creator,       // creator of the pool
        address _governor,      // dreamcatcher governor contract
        string memory _name,    // name of the pool
        uint256 _duration,      // duration of the initial funding round
        uint256 _required,      // amount of matic required to pass the pool if applicable
        bool _whitelisted,      // only whitelisted domains can participate
        bool _transferable      // can be transfered to external domains note you cant transfer until the funding round is officially over
    ) {

        logic    = _logic;
        creator  = _creator;
        governor = _governor;

        // get minDuration && maxDuration from governor
        funding.minDuration =;
        funding.maxDuration =;

        // -closed -no_end
        if (_class == 0) {

            require(_logic != address(0));
            require(_creator != address(0));
            require(_governor != address(0));
            require(_duration >= 0);
            require(_required >= 0);

            if (_minDuration != 0) {
                require(_duration >= _minDuration);
                require(_minDuration <= _maxDuration);
            }

            if (_maxDuration != 0) {
                require(_duration <= _maxDuration);
            }

            uint256 _now         = block.timestamp;
            funding.begin        = _now;
            funding.duration     = _duration;
            funding.end          = _now + _duration;
            funding.required     = _required;
            funding.whitelisted  = _whitelisted;
            funding.transferable = _transferable;
        }

        // -closed -w_end
        if (_class == 1) {

        }
        
    }

    function _updateWhitelist_(address _domain, bool _state) public returns (bool) {
        require(
            msg.sender == logic ||
            msg.sender == creator
        );
        require(_domain != address(0));
        whitelist[_domain] = _state;
        return true;
    }

    function whitelistOf(address _domain) public view returns (bool) {return whitelist[_domain];}
}