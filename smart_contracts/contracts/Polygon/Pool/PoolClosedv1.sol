// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "smart_contracts/contracts/Polygon/Pool/ERC20.sol";

contract State {
    address creator;
    address manager;
    string name;
    string description;
    uint256 balanceWei;
    ERC20 nativeToken;
    bool whitelisted;
    uint256 fundingStart;
    uint256 fundingMinDuration;
    uint256 fundingMaxDuration;
    uint256 fundingDuration;
    uint256 fundingEnd;
    uint256 requestedWei;
    uint256 requiredWei;
}

contract PoolClosedv1 is State {
    struct My {
        string name;
        uint256 balanceWei;
        ERC20Cap nativeToken;
        address creator;
        address manager;
    }
    struct Settings {
        bool isWhitelistOnly;
    }
    // =.=.= LIFE CYCLE OF A POOL =.=.=
    struct Funding {
        uint256 start;
        uint256 minDuration;
        uint256 maxDuration;
        uint256 duration;
        uint256 close;
        uint256 requestedWei;
        uint256 requiredWei;
    }
    My private my;
    Settings private settings;
    Funding private funding;
    mapping(address => bool) private whitelist;
    mapping(address => uint256) private holdings;
    modifier onlyWhitelisted() {
        require(isWhitelistOnly && whitelist[msg.sender]);
        _;
    }
    modifier onlyCreator() {
        require(my.creator == msg.sender);
        _;
    }

    constructor(
        address _manager,
        string memory _name,
        string memory _tknName,
        string memory _tknSymbol,
        uin8 _tknDecimals,
        uint256 _tknMaxSupply,
        uint256 _tknInitialSupply,
        uint256 _fundingDuration
    ) {
        require(
            msg.value >= 1 &&
                _tknInitialSupply <= _tknMaxSupply &&
                _fundingDuration >= 1 weeks
        );
        my.creator = msg.sender;
        my.manager = _manager;
        my.name = _name;
        my.nativeToken = new ERC20Cap(
            address(this),
            _tknName,
            _tknSymbol,
            _tknDecimals,
            _tknMaxSupply
        );
        funding.start = block.timestamp;
        funding.duration = _fundingDuration;
        funding.close = funding.start + _fundingDuration;
        my.balanceWei += msg.value;
        mint(my.creator, _tknInitialSupply);
    }

    function contribute() public onlyWhitelisted returns (bool) {
        address _buyers = msg.sender;
        address _seller = address(this);
        uint256 _value = msg.value;
        uint256 _balance = my.balanceWei;
        uint256 _supply = my.nativeToken.totalSupply();
        require(
            _balance > 0 &&
                _value > 0 &&
                _supply > 0 &&
                funding.close <= block.timestamp
        );
        uint256 _amountOfTokensToMint = (_value * _balance) / _supply;
        mint(_buyers, _amountOfTokensToMint);
    }
}
