// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/ERC20.sol";

contract State {
    /** basic authenticator */
    address logic;
    address governor;
    
    modifier onlyLogic() {
        require(msg.sender == logic);
        _;
    }

    modifier onlyGovernor() {
        require(msg.sender == governor);
        _;
    }

    /** initial funding round */
    struct InitialFundingRound {
        uint256 duration;
        uint256 minDuration;
        uint256 maxDuration;
        uint256 start;
        uint256 end;
        uint256 required;
        bool whitelisted;
        bool transferable;
        bool set;
    } InitialFundingRound private initialFundingRound;

    function _setUpInitialFundingRound_(
        uint256 _duration,
        uint256 _required,
        bool _whitelisted,
        bool _transferable
    ) public onlyLogic returns (bool) {

        if (initialFundingRound.minDuration != 0) {
            require(_duration >= initialFundingRound.minDuration);
        }
        
        if (initialFundingRound.maxDuration != 0) {
            require(_duration <= initialFundingRound.maxDuration);
        }

        require(initialFundingRound.set == false);
        uint256 _now = block.timestamp;
        initialFundingRound.duration = _duration;
        initialFundingRound.start = _now;
        initialFundingRound.end = _now + _duration;
        initialFundingRound.required = _required;
        initialFundingRound.whitelisted = _whitelisted;
        initialFundingRound.transferable = _transferable;
        initialFundingRound.set = true;
        return true;
    }

    function __updateInitialFundingRoundParam__(
        uint256 _minDuration,
        uint256 _maxDuration
    ) onlyGovernor returns (bool) {
        require(_minDuration >= 0);
        require(_maxDuration >= _minDuration);
        initialFundingRound.minDuration = _minDuration;
        initialFundingRound.maxDuration = _maxDuration;
        return true;
    }

    /** fund meta data  */
    struct My {
        Token nativeToken;
        string name;
        string description;
    } My private my;

    function _setUp_(
        Token _nativeToken,
        string memory _name,
        string memory _description
    ) public onlyLogic returns (bool) {
        my.nativeToken = _nativeToken;
        my.name = _name;
        my.description = _description;
        return true;
    }

    function _update_(
        string memory _name,
        string memory _description
    ) public onlyLogic returns (bool) {
        my.name = _name;
        my.description = _description;
        return true;
    }

    /** whitelist */
    mapping(address => bool) private whitelist;
    
    function _whitelist_(address _domain, bool _newState) public onlyLogic returns (bool) {
        whitelist[_domain] = _newState;
        return true;
    }

    constructor() {}
}