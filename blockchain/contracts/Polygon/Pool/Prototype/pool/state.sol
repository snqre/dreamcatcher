// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IState {
    function push_profile(
        address  _address,
        bool     _is_manager,
        bool     _is_on_whitelist,
        uint256  _flux
    ) external;

    function pull_profile(address _address) external view returns (
        bool,
        bool,
        uint256
    );

    function withdraw(uint256 _value_in_wei) external;

    function push_authenticator(
        address _logic,
        address _creator,
        address _governor
    ) external;

    function pull_authenticator() external view returns (
        address,
        address,
        address
    );

    function push_launch(
        uint256 _start,
        uint256 _end,
        uint256 _required,
        bool _whitelisted,
        bool _success
    ) external;

    function pull_launch() external view returns (
        uint256,
        uint256,
        uint256,
        bool,
        bool
    );

    function push_yield(
        uint256 _start,
        uint256 _end
    ) external; 

    function pull_yield() external view returns (
        uint256,
        uint256
    );

    event Deposit(
        address indexed _from,
        uint256 _value_of_matic
    );

    event Withdraw(
        address indexed _to,
        uint256 _value_of_matic
    );

    event UpdateToYield(
        uint256  _start,
        uint256  _end
    );

    event UpdateToLaunch(
        uint256  _start,
        uint256  _end,
        uint256  _required,
        bool     _whitelisted,
        bool     _success
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
        require(locked ==false, "state: locked ==false");
        locked =true;
        _;
        locked =false;
    }
}

contract Authenticator {
    address logic;
    modifier only_logic() {
        require(msg.sender ==logic, "state: msg.sender !=logic");
        _;
    }

    address creator;
    modifier only_creator() {
        require(msg.sender ==creator, "state: msg.sender !=creator");
        _;
    }

    address governor;
    modifier only_governor() {
        require(msg.sender ==governor, "state: msg.sender !=governor");
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

    struct Yield {
        uint256 start;
        uint256 end;
    }

    Yield yield;

    constructor(
        address  _logic,
        address  _creator,
        address  _governor,
        string   memory _name,
        uint256  _duration,
        uint256  _required,
        bool     _whitelisted
    ) {
        require(_required >= 0, "state: _required !>=0");
        require(_duration >=1 weeks, "state: _duration !>=1 weeks");
        require(_duration <=9 weeks, "state: _duration !<=9 weeks");

        uint256 _now         =block.timestamp;
        launch.start         =_now;
        launch.end           =_now +_duration;
        launch.required      =_required;
        launch.whitelisted   =_whitelisted;
        
        if (_required ==0) {launch.success =true;}

        require(_logic !=address(0), "state: _logic ==address(0)");
        require(_creator !=address(0), "state: _creator ==address(0)");

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

    function push_profile(
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

    function pull_profile(address _address) public view returns (
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

    function deposit() external payable {
        emit Deposit(
            _from,
            _value_of_matic
        );
    }

    fallback() external payable {
        emit Deposit(
            _from,
            _value_of_matic
        );
    }

    function withdraw(uint256 _value_in_wei) public only_logic one_at_a_time {
        address payable _to =payable(logic);
        _to.transfer(_value_in_wei);
    }

    function push_authenticator(
        address _logic,
        address _creator,
        address _governor
        
    ) public only_logic one_at_a_time {
        require(_logic !=address(0), "state: _logic ==address(0)");
        require(_creator !=address(0), "state: _creator ==address(0)");
        require(_governor !=address(0), "state: _governor ==address(0)");

        logic =_logic;
        creator =_creator;
        governor =_governor;

        emit UpdateToAuthenticator(
            _logic,
            _creator,
            _governor
        );
    }

    function pull_authenticator() public view returns (
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

    function push_launch(
        uint256 _start,
        uint256 _end,
        uint256 _required,
        bool _whitelisted,
        bool _success

    ) public only_logic one_at_a_time {
        launch.start         =_start;
        launch.end           =_end;
        launch.required      =_required;
        launch.whitelisted   =_whitelisted;
        launch.success       =_success;

        emit UpdateToLaunch(
            _start,
            _end,
            _required,
            _whitelisted,
            _success
        );
    }

    function pull_launch() public view returns (
        uint256,
        uint256,
        uint256,
        bool,
        bool

    ) {
        return (
            launch.start,
            launch.end,
            launch.required,
            launch.whitelisted,
            launch.success
        );
    }

    function push_yield(
        uint256 _start,
        uint256 _end

    ) public only_logic one_at_a_time {
        require(_start >=launch.end +1 weeks, "state: _start !>=launch.end");
        require(_end >=_start +1 weeks, "state: _end !>=_start");
        yield.start  =_start;
        yield.end    =_end;

        emit UpdateToYield(
            _start,
            _end
        );
    }

    function pull_yield() public view returns (
        uint256,
        uint256

    ) {
        return (
            yield.start,
            yield.end
        );
    }
}