// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/** transferable collateral
hold 2000 matic then 2000 matic worth can be transfered out and used for the transaction
the rest will then be unloceked once the assets are present and transaction is complete

 */

interface IState {
    event UpdateToFundingSettings(
        uint256 _begin,
        uint256 _duration,
        uint256 _end,
        uint256 _required,
        bool _whitelisted,
        bool _transferable,
        bool _successful
    );

    event UpdateToHarvestSettings(
        uint256 _secondsToHarvest,
        uint256 _begin,
        uint256 _duration,
        uint256 _end
    );

    event Update(
        string _name,
        address _logic,
        address _creator,
        address _governor
    );

    event UpdateToDomain(
        address indexed _domain,
        bool _whitelisted,
        bool _manager
    );
}

contract State is IState {
    mapping(address => bool) private manager;

    // whitelist
    mapping(address => bool) private whitelist;

    struct My {
        string name;
        address logic;
        address creator;
        address governor;
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

    struct Settings {
        bool decentralized; // anyone can vote to where to swap or transfer funds
        bool veto;          // managers can veto bad proposals
    } Settings private settings;

    struct Proposal {
        string caption;
        string description;
        uint256 duration;
    } Proposal private proposal;

    mapping(address => Proposal[]) private proposalsCreated;
    mapping(address => string) private proposalsVotedOn;

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
        require(_logic !=address(0));
        require(_creator !=address(0));
        require(_governor !=address(0));
        require(_duration >=0);
        require(_required >=0);

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

        my.name =_name;

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


    }

    receive() external payable {}

    function _withdraw_(uint256 _valueWei) public {
        require(msg.sender ==logic);
        address payable _to =payable(logic);
        _to.transfer(_valueWei);
    }

    function setFunding(
        uint256 _begin,
        uint256 _duration,
        uint256 _end,
        uint256 _required,
        bool _whitelisted,
        bool _transferable,
        bool _successful
    ) public {
        require(msg.sender ==logic);
        funding.begin        =_begin;
        funding.duration     =_duration;
        funding.end          =_end;
        funding.required     =_required;
        funding.whitelisted  =_whitelisted;
        funding.transferable =_transferable;
        funding.successful   =_successful;

        emit UpdateToFundingSettings(
            _begin,
            _duration,
            _end,
            _required,
            _whitelisted,
            _transferable,
            _successful
        );
    }

    function getFunding() public view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        bool,
        bool
    ) {
        return (
            funding.begin,
            funding.minDuration,
            funding.maxDuration,
            funding.duration,
            funding.end,
            funding.required,
            funding.whitelisted,
            funding.transferable,
            funding.successful
        );
    }

    function setHarvest(
        uint256 _secondsToHarvest,
        uint256 _begin,
        uint256 _duration,
        uint256 _end
    ) public {
        require(msg.sender ==logic);
        harvest.secondsToHarvest =_secondsToHarvest;
        harvest.begin            =_begin;
        harvest.duration         =_duration;
        harvest.end              =_end;

        emit UpdateToHarvestSettings(
            _secondsToHarvest,
            _begin,
            _duration,
            _end
        );
    }

    function getHarvest() public view returns (
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            harvest.secondsToHarvest,
            harvest.begin,
            harvest.duration,
            harvest.end
        );
    }

    function get() public view returns (
        string,
        address,
        address,
        address
    ) {
        return (
            my.name,
            my.logic,
            my.creator,
            my.governor
        );
    }

    function set(
        string _name,
        address _logic,
        address _creator,
        address _governor
    ) public returns () {
        my.name     =_name;
        my.logic    =_logic;
        my.creator  =_creator;
        my.governor =_governor;

        emit Update(
            _name,
            _logic,
            _creator,
            _governor
        );
    }

    function getOf() public returns (
        bool,
        bool
    ) {
        return (
            whitelist[_domain],
            manager[_domain]
        );
    }

    function setOf(
        address _domain,
        bool _whitelisted,
        bool _manager
    ) public {
        whitelist[_domain]   =_whitelisted;
        manager[_domain]     =_manager;

        emit UpdateToDomain(
            _domain,
            _whitelisted,
            _manager
        );
    }
}