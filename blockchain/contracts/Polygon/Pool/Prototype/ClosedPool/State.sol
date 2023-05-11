// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/** transferable collateral
hold 2000 matic then 2000 matic worth can be transfered out and used for the transaction
the rest will then be unloceked once the assets are present and transaction is complete

 */

interface IState {
    event PoolCreated(
        string _name,
        address indexed _logic
        address indexed _creator,
        address indexed _governor,
        uint256 _required
    );
}

contract State is IState {
    address logic;
    address creator;
    address governor;

    struct My {
        string name;
    }

    struct Funding {
        uint256 begin;
        uint256 minDuration;
        uint256 maxDuration;
        uint256 duration;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool transferable;
        bool successful;
    } Funding private funding;

    struct Harvest {
        uint256 secondsToHarvest;
        uint256 begin;
        uint256 duration;
        uint256 end;
    } Harvest private harvest;

    // whitelist
    mapping(address => bool) private whitelist;

    constructor(
        address _logic,            // logic contract
        address _creator,          // creator of the pool
        address _governor,         // dreamcatcher governor contract
        string memory _name,       // name of the pool
        uint256 _duration,         // duration of the initial funding round
        uint256 _required,         // amount of matic required to pass the pool if applicable
        bool _whitelisted,         // only whitelisted domains can participate
        bool _transferable         // can be transfered to external domains note you cant transfer until the funding round is officially over
        uint256 _secondsToHarvest  // time in seconds until harvest period if applicable
        uint256 _durationHarvest   // duration of the harvest period
    ) {
        require(_logic != address(0));
        require(_creator != address(0));
        require(_governor != address(0));
        require(_duration >= 0);
        require(_required >= 0);

        if (_required ==0) {funding.successful =true;}

        // get minDuration && maxDuration from governor
        uint256 _minDuration;
        uint256 _maxDuration;

        funding.minDuration =;
        funding.maxDuration =;

        if (_minDuration !=0) {
            require(_duration >= _minDuration);
            require(_minDuration <= _maxDuration);
        }

        if (_maxDuration !=0) {
            require(_duration <= _maxDuration);
        }

        logic    =_logic;
        creator  =_creator;
        governor =_governor;

        uint256 _now         =block.timestamp;
        funding.begin        =_now;
        funding.duration     =_duration;
        funding.end          =_now + _duration;
        funding.required     =_required;
        funding.whitelisted  =_whitelisted;
        funding.transferable =_transferable;

        my.name = _name;

        // -closed -no_end
        if (_secondsToHarvest ==0) {

            harvest.secondsToHarvest =0;
            harvest.begin =0;
            harvest.duration =0;
            harvest.end =0;
        }

        // -closed -w_end
        if (_secondsToHarvest !=0) {

            require(_secondsToHarvest >=_now +_duration);

            harvest.secondsToHarvest =_secondsToHarvest;
            harvest.begin =_now +_secondsToHarvest;
            harvest.duration =_durationHarvest;
            harvest.end =_now +_secondsToHarvest +_durationHarvest;
        }

        // the creator needs to be able to contribute if the pool is whitelisted as well as the logic contract to move funds from logic to state
        _updateWhitelist_(_logic, true);
        _updateWhitelist_(_creator, true);

        emit PoolCreated(
            _name,
            _creator,
            _governor,
            _required
        );
        
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