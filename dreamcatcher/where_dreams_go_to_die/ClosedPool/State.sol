// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IState {
    /** although set functions are public they can only changed by the logic contract */
    function withdraw(uint256 _valueWei) external;
    function setFunding(
        uint256 _begin,
        uint256 _duration,
        uint256 _end,
        uint256 _required,
        bool _whitelisted,
        bool _transferable,
        bool _successful
    ) external;

    function getFunding() external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        bool,
        bool
    );

    function setHarvest(
        uint256 _secondsToHarvest,
        uint256 _begin,
        uint256 _duration,
        uint256 _end
    ) external;

    function getHarvest() external view returns (
        uint256,
        uint256,
        uint256,
        uint256
    );

    function set(
        string _name,
        address _logic,
        address _creator,
        address _governor
    ) external;

    function get() external view returns (
        string,
        address,
        address,
        address
    );

    function setOf(
        address _domain,
        bool _isOnWhitelist,
        bool _isManager,
        uint256 _contribution
    ) external;

    function getOf(address _domain) external returns (
        bool,
        bool,
        uint256
    );

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

    event UpdateOf(
        address indexed _domain,
        bool _isLogic,
        bool _isCreator,
        bool _isManager,
        bool _isGovernor,
        bool _isOnWhitelist,
        uint256 _flux,
        uint256 _guarantee,
        uint256 _pending
    );

    event PoolCreated(
        address  indexed _logic,
        address  indexed _creator,
        address  indexed _governor,
        string   _nameOfPool,
        uint256  _fundingRoundDuration,
        uint256  _maticRequired,
        bool     _onlyForWhitelisted,
        bool     _transferable,
        uint256  _timeUntilHarvest,
        uint256  _durationOfHarvest
    );
}

contract State is IState {
    string name;
    
    /** Profile */
    mapping(address =>bool)      private isLogic;
    mapping(address =>bool)      private isCreator;
    mapping(address =>bool)      private isManager;
    mapping(address =>bool)      private isGovernor;
    mapping(address =>bool)      private isOnWhitelist;
    mapping(address =>uint256)   private flux;
    mapping(address =>uint256)   private guarantee;
    mapping(address =>uint256)   private pending;

    struct InitialFunding {
        uint256 start;
        uint256 duration;
        uint256 end;
        uint256 required;
        uint256 current;
        bool onlyWhitelisted;
        bool managerCanTransfer;
        bool managerCanSwap;
        bool onlyTransferOnGuarantee;
        bool successful;
    } InitialFunding private initialFunding;

    struct Funding {
        uint256 begin;
        uint256 duration;
        uint256 end;
        uint256 required;
        bool isWhitelisted;
        bool allowTransfer;
        bool allowTransferOnlyOnGuarantee;
        bool isSuccessful;
    } Funding private funding;

    struct Harvest {
        uint256 minSecondsToHarvest;
        uint256 maxSecondsToHarvest;
        uint256 secondsToHarvest;
        uint256 begin;
        uint256 minDuration;
        uint256 maxDuration;
        uint256 duration;
        uint256 end;
    } Harvest private harvest;

    struct Yield {
        uint256 start;
        uint256 duration;
        uint256 end;
    }

    constructor(
        
    ) {
        require(_logic !=address(0));
        require(_creator !=address(0));
        require(_governor !=address(0));
        require(_duration >=0);
        require(_required >=0);
        require(_secondsToHarvest >= 0);
        require(_durationHarvest >= 0);

        if (_required ==0) {funding.successful =true;}

        uint256 _minDuration =1 weeks;
        uint256 _maxDuration =48 weeks;

        require(_minDuration >= 0);
        require(_maxDuration >= _minDuration);

        funding.minDuration =_minDuration;
        funding.maxDuration =_maxDuration;

        require(_duration <= _maxDuration);
        require(_duration >= _minDuration);

        my.logic    =_logic;
        my.creator  =_creator;
        my.governor =_governor;

        uint256 _now         =block.timestamp;
        funding.begin        =_now;
        funding.duration     =_duration;
        funding.end          =_now + _duration;
        funding.required     =_required;
        funding.whitelisted  =_whitelisted;
        funding.transferable =_transferable;

        my.name =_name;

        harvest.minDuration =_minDuration;
        harvest.maxDuration =_maxDuration;

        require(_durationHarvest <=_minDuration);
        require(_durationHarvest >=_maxDuration);

        uint256 _minSecondsToHarvest =1 weeks;
        uint256 _maxSecondsToHarvest =480 weeks;

        require(_minSecondsToHarvest >=0);
        require(_maxSecondsToHarvest >=_minSecondsToHarvest);

        require(_secondsToHarvest >=_minSecondsToHarvest);
        require(_secondsToHarvest <=_maxSecondsToHarvest);

        harvest.secondsToHarvest =_secondsToHarvest;
        harvest.begin =funding.end +_secondsToHarvest;
        harvest.duration =_durationHarvest;
        harvest.end =harvest.begin +_durationHarvest;

        emit PoolCreated(
            _logic,
            _creator,
            _governor,
            _name,
            _duration,
            _required,
            _whitelisted,
            _transferable,
            _secondsToHarvest,
            _durationHarvest
        );
    }

    function withdraw(uint256 _valueWei) public {
        require(msg.sender ==logic);
        address payable _to =payable(logic);
        _to.transfer(_valueWei);
    }

    function setFunding(
        uint256  _begin,
        uint256  _duration,
        uint256  _end,
        uint256  _required,
        bool     _isWhitelisted,
        bool     _allowTransfer,
        bool     _allowTransferOnlyOnGUarantee,
        bool     _isSuccessful

    ) public {
        require(isLogic[msg.sender]);
        Funding memory _newFundingSettings =Funding({
            begin:                           _begin,
            duration:                        _duration,
            end:                             _end,
            required:                        _required,
            isWhitelisted:                   _isWhitelisted,
            allowTransfer:                   _allowTransfer,
            allowTransferOnlyOnGuarantee:    _allowTransferOnlyOnGuarantee,
            isSuccessful:                    _isSuccessful
        });
        
        funding =_newFundingSettings;
    }

    function getFunding() public view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        bool,
        bool,
        bool

    ) {
        return (
            funding.begin,
            funding.duration,
            funding.end,
            funding.required,
            funding.isWhitelisted,
            funding.allowTransfer,
            funding.allowTransferOnlyOnGuarantee,
            funding.isSuccessful
        );
    }

    function setOf(
        address  _domain,
        bool     _isLogic,
        bool     _isCreator,
        bool     _isManager,
        bool     _isGovernor,
        bool     _isOnWhitelist,
        uint256  _flux,
        uint256  _guarantee,
        uint256  _pending

    ) public {
        require(isLogic[msg.sender]);
        isLogic         [_domain] =_isLogic;
        isCreator       [_domain] =_isCreator;
        isManager       [_domain] =_isManager;
        isGovernor      [_domain] =_isGovernor;
        isOnWhitelist   [_domain] =_isOnWhitelist;
        flux            [_domain] =_flux;
        guarantee       [_domain] =_guagantee;
        pending         [_domain] =_pending;

        emit UpdateOf(
            _domain,
            _isLogic,
            _isCreator,
            _isManager,
            _isGovernor,
            _isOnWhitelist,
            _flux,
            _guarantee,
            _pending
        );
    }

    function getOf(address _domain) public view returns (
        bool     _isLogic,
        bool     _isCreator,
        bool     _isManager,
        bool     _isGovernor,
        bool     _isOnWhitelist,
        uint256  _flux,
        uint256  _guarantee,
        uint256  _pending

    ) {
        return (
            isLogic         [_domain],
            isCreator       [_domain],
            isManager       [_domain],
            isGovernor      [_domain],
            isOnWhitelist   [_domain],
            flux            [_domain],
            guarantee       [_domain],
            pending         [_domain]
        );
    }
}