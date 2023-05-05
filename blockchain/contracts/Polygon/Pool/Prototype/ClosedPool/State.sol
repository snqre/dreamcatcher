// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

contract State {
    uint256 INF = type(uint256).max;
    mapping(address=>uint256) private contribution;
    mapping(address=>bool) private white;
    address admin;

    Protocol private protocol;

    struct Protocol {
        Settings settings;
        Funding funding;
    }

    struct Settings {
        Toggles toggles;
    }

    struct Toggles {
        bool extension;
        bool whitelist;
    }

    struct Funding {
        Launch launch;
        Distribution distribution;
    }

    struct Launch {
        uint256 begin;
        uint256 duration;
        uint256 minimum;
        uint256 maximum;
        uint256 balance;
    }

    struct Distribution {
        uint256 begin;
        uint256 duration;
        uint256 balance;
    }

    event Whitelist(address indexed _owner, bool _new_value);
    event AdminSwap(address indexed _new_admin);

    constructor(
        address _admin = msg.sender,
        uint256 _start = block.timestamp,
        bool _extension = false,
        bool _whitelist = false,
        uint256 _duration_launch = 12 weeks,
        uint256 _min_deposit = 1,
        uint256 _max_deposit = INF,
        uint256 _duration_until_distribution = 480 weeks,
        uint256 _duration_distribution = 12 weeks
    ) {
        require(
            _admin != address(0) &&
            _start >= block.timestamp &&
            _duration_launch >= 1 weeks &&
            _duration_launch <= 24 weeks &&
            _min_deposit >= 0 &&
            _max_deposit <= INF &&
            _duration_until_distribution >= _start + _duration_launch + 48 weeks,
            _duration_distribution >= 1 weeks &&
            _duration_distribution <= 48 weeks
        );
        admin = _admin;
        // default toggles state
        protocol.settings.toggles.extension = _extension;
        protocol.settings.toggles.whitelist = _whitelist;
        // default funding launch
        protocol.funding.launch.begin = _start;
        protocol.funding.launch.duration = _duration_launch;
        protocol.funding.launch.minimum = _min_deposit;
        protocol.funding.launch.maximum = _max_deposit;
        // default funding distribution
        protocol.funding.distribution.begin = _duration_until_distribution;
        protocol.funding.distribution.duration = _duration_distribution;
    }

    function whitelist(address _owner, bool _new_value = true) public returns (bool) {
        require(msg.sender == admin, "State: msg.sender != admin");
        white[_owner] = true;
        emit Whitelist(_owner, _new_value);
        return true;
    }

    function swap_admin(address _new_admin) public returns (bool) {
        require(msg.sender == admin, "State: msg.sender != admin");
        admin = _new_admin;
        emit AdminSwap(_new_admin);
    }

    function extension() public view returns (bool) {return protocol.settings.toggles.extension;}
    function whitelist() public view returns (bool) {return protocol.settings.toggles.whitelist;}
    function launch_begin() public view returns (uint256) {return protocol.settings.launch.begin;}
    function launch_duration() public view returns (uint256) {return protocol.settings.launch.duration;}
    function launch_minimum() public view returns (uint256) {return protocol.settings.launch.minimum;}
    function launch_maximum() public view returns (uint256) {return protocol.settings.launch.maximum;}
}
