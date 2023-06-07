// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

// need to import aggregator, access control

interface AggregatorV3Interface { // chainlink
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    );

    function latestRoundData() external view returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    );
}

interface IMedium { // see enum for currencies
    event PushedNewPairToStorage(uint currency, address indexed tokenContract, address indexed feed);
}

contract Medium is IMedium, AccessControl {
    enum Currency {
        USD, 
        ETH, 
        BTC, 
        GBP, 
        EUR
    }

    /*---------------------------------------------------------------- STATE **/
    // [ Currency ][ Token Contract ] = Chainlink Feed Contract
    mapping(uint256 => mapping (address => address)) public feeds;

    /*---------------------------------------------------------------- CONSTRUCTOR **/
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*---------------------------------------------------------------- PUSHNEWPAIRTOSTORAGE **/
    function _pushNewPairToStorage(Currency currency, address tokenContract, address feed, bool override_) internal {
        // a pair is composed of a token contract and a chainlink feed on polygon
        if (override_ == false) {
            require(tokenContract != address(0));
            require(feed != address(0));
        }

        feeds[currency][tokenContract] = feed;

        emit PushedNewPairToStorage(currency, tokenContract, feed);
    }

    /*---------------------------------------------------------------- GETFEEDFROMSTORAGE **/
    function _getFeedFromStorage(Currency currency, address tokenContract) internal {
        return feeds[currency][tokenContract];
    }

    /*---------------------------------------------------------------- GETPRICE **/
    function _getPrice(Currency currency, address tokenContract, bool override_) internal returns (uint) {
        if (override_ == false) {
            require(tokenContract != address(0));
        }

        // get price from feed
        address feed = _getFeedFromStorage(currency, tokenContract);
        AggregatorV3Interface aggregator = AggregatorV3Interface(feed);
        (, int256 agrPrice, , , ) = aggregator.latestRoundData();

        uint price = uint256(agrPrice);

        if (override_ == false) {
            require(price > 0, "Medium::_getPrice(): price <= 0");
        }

        return price;
    }

    /*---------------------------------------------------------------- PUSHNEWPAIRTOSTORAGE **/
    function pushNewPairToStorage(Currency currency, address tokenContract, address feed) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pushNewPairToStorage(currency, tokenContract, feed, false);
    }

    /*---------------------------------------------------------------- GETPRICE **/
    function getPrice(Currency currency, address tokenContract, bool override_) public returns (uint) {
        // override_ will disable all checks and price may return zero instead of reverting on zero
        _getPrice(currency, tokenContract, override_);
    }
}