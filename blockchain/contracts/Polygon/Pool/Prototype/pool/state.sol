// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IState {
    function update_profile(
        address  _address,
        bool     _is_manager,
        bool     _is_on_whitelist,
        uint256  _flux
    ) external;

    function get_profile(address _address) external view returns (
        bool,
        bool,
        uint256
    );

    function withdraw(uint256 _value_in_wei) external;

    function update_authenticator(
        address _logic,
        address _creator,
        address _governor
    ) external;

    function get_authenticator() external view returns (
        address,
        address,
        address
    );

    event UpdateToAuthenticator(
        address  indexed _new_logic,
        address  indexed _new_creator,
        address  indexed _new_governor
    );

    event UpdateToProfile(
        address  indexed _address,
        bool     _is_manager,
        bool     _is_on_whitelist,
        uint256  _flux
    );

    event PoolCreated(
        address  indexed _logic,
        address  indexed _creator,
        address  indexed _governor,
        string   _name,
        uint256  _inception,
        uint256  _funding_round_end,
        uint256  _required,
        bool     _whitelisted
    );
}

contract Safety {
    bool locked;
    modifier one_at_a_time() {
        require(locked ==false);
        locked =true;
        _;
        locked =false;
    }
}

contract Authenticator {
    address logic;
    modifier only_logic() {
        require(msg.sender ==logic);
        _;
    }

    address creator;
    modifier only_creator() {
        require(msg.sender ==creator);
        _;
    }

    address governor;
    modifier only_governor() {
        require(msg.sender ==governor);
        _;
    }
}

contract State is IState, Safety, Authenticator {
    string name;

    mapping(address =>bool)      private is_manager;
    mapping(address =>bool)      private is_on_Whitelist;
    mapping(address =>uint256)   private flux;

    struct Launch {
        uint256  start;
        uint256  end;
        uint256  required;
        bool     whitelisted;
        bool     success;
    }

    Launch launch;

    constructor(
        address  _logic,
        address  _creator,
        address  _governor,
        string   _name,
        uint256  _duration,
        uint256  _required,
        bool     _whitelisted
    ) {
        require(_duration >= 0);
        require(_required >= 0);
        require(_duration >=1 weeks);
        require(_duration <=1 years);

        uint256 _now         =block.timestamp;
        launch.start         =_now;
        launch.end           =_now +_duration;
        launch.required      =_required;
        launch.whitelisted   =_whitelisted;
        
        if (_required ==0) {launch.success =true;}

        require(_logic !=address(0));
        require(_creator !=address(0));

        logic    =_logic;
        creator  =_creator;

        name     =_name;

        emit PoolCreated(
            _logic,
            _creator,
            _governor,
            _name,
            _now,
            launch.end,
            _required,
            _whitelisted
        );
    }

    function update_profile(
        address  _address,
        bool     _is_manager,
        bool     _is_on_whitelist,
        uint256  _flux

    ) public only_logic one_at_a_time {
        is_manager      [_address] =_is_manager;
        is_on_Whitelist [_address] =_is_on_whitelist;
        flux            [_address] =_flux;

        emit UpdateToProfile(
            _address,
            _is_manager,
            _is_on_whitelist,
            _flux
        );
    }

    function get_profile(address _address) public view returns (
        bool,
        bool,
        uint256
    ) {
        return (
            is_manager      [_address],
            is_on_Whitelist [_address],
            flux            [_address]
        );
    }

    function withdraw(uint256 _value_in_wei) public only_logic one_at_a_time {
        address payable _to =payable(logic);
        _to.transfer(_value_in_wei);
    }

    function update_authenticator(
        address _logic,
        address _creator,
        address _governor
        
    ) public only_logic one_at_a_time {
        require(_logic !=address(0));
        require(_creator !=address(0));
        require(_governor !=address(0));

        logic =_logic;
        creator =_creator;
        governor =_governor;

        emit UpdateToAuthenticator(
            _logic,
            _creator,
            _governor
        );
    }

    function get_authenticator() public view returns (
        address,
        address,
        address

    ) {
        return (
            logic,
            creator,
            governor
        );
    }
    
}