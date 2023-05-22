// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
/** chainlink */
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkRequestInterface.sol";
/** openzeppelin */
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

interface IMedium {
    event SetFeed(uint256 currency, address indexed contract_, address indexed feed);

}

contract Medium is IMedium {
    /** curr > contract = feed */
    mapping(uint256 => mapping (address => address)) public currencyContractToFeed;

    enum currency {USD, ETH, BTC, GBP, EUR}

    constructor() {}

    /*----------------------------------------------------------------**/
    function _setFeed(uint256 currency, address contract_, address feed) internal {
        /** moderation */
        require(currency >= 0, "Medium::_setFeed: currency < 0");
        require(currency <= type(uint256).max, "Medium::_setFeed: currency > type(uint256).max");
        require(contract_ != address(0x0), "Medium::_setFeed: contract_ == address(0x0)");
        require(feed != address(0x0), "Medium::_setFeed: feed == address(0x0)");
        /** modify */
        currencyContractToFeed[currency][contract_] = feed;
        /** event */
        emit SetFeed(currency, contract_, feed);
    }

    function _setFeeds(uint256 currency, address[] memory contracts, address[] memory feeds) internal {
        uint256 contractsSize = contracts.length;
        uint256 feedsSize = feeds.length;
        require(contractsSize == feedsSize, "Medium::_setFeeds: contractsSize != feedsSize");
        for (uint256 i = 0; i < contractsSize; i++) {
            _setFeed(currency, contracts[i], feeds[i]);
        }
    }

    /*----------------------------------------------------------------**/
    function _getFeed(uint256 currency, address contract_) internal returns (address) {
        /** moderation */
        require(currency >= 0, "Medium::_getFeed: currency < 0");
        require(currency <= type(uint256).max, "Medium::_getFeed: currency > type(uint256).max");
        require(contract_ != address(0x0), "Medium::_getFeed: contract_ == address(0x0)");
        /** check and return */
        address feed = currencyContractToFeed[currency][contract_];
        require(feed != address(0x0), "Medium::_getFeed: response == address(0x0)");
        return feed;
    }

    function _getFeeds(uint256 currency, address[] contracts) internal returns (address[] memory) {
        address[] memory feeds;
        uint256 contractsSize = contracts.length;
        require(contractsSize >= 1, "Medium::_getFeeds: contractsSize < 1");
        for (uint256 i = 0; i < contractsSize; i++) {
            feeds.push(_getFeed(currency, contracts[i]));
        }
        return feeds;
    }

    /*----------------------------------------------------------------**/
    function _getPrice(uint256 currency, address contract_) internal returns (uint256) {
        /** moderation */
        require(currency >= 0, "Medium::_getPrice: currency < 0");
        require(currency <= type(uint256).max, "Medium::_getPrice: currency > type(uint256).max");
        require(contract_ != address(0x0), "Medium::_getPrice: contract_ == address(0x0)");
        /** gather */
        address feed = _getFeed(currency, contract_);
        AggregatorV3Interface aggregator = AggregatorV3Interface(feed);
        (, int256 price, , , ) = aggregator.latestRoundData();
        /** check and return */
        require (uint256(price) > 0, "Medium::_getPrice: uint256(price) <= 0");
        return uint256(price);
    }

    function _getPrices(uint256 currency, address[] contracts) internal results (uint256[]) {
        uint256[] memory prices;
        uint256 contractsSize = contracts.length;
        require(contractsSize >= 1, "Medium::_getFeeds: contractsSize < 1");
        for (uint256 i = 0; i < contractsSize; i++) {
            prices.push(_getPrice(currency, contracts[i]));
        }
        return prices;
    }

    /*----------------------------------------------------------------**/
    function setFeed(bytes memory args) public onlyOwner returns (bool success) {
        (
            uint256 currency,
            address contract_,
            address feed
        ) = abi.decode(args, (uint256, address, address));
        _setFeed(currency, contract_, feed);
        return true;
    }

    function setFeeds(bytes memory args) public onlyOwner returns (bool success) {
        (
            uint256 currency,
            address[] memory contracts,
            address[] memory feeds
        ) = abi.decode(args, (uint256, address[], address[]));
        _setFeeds(currency, contracts, feeds);
        return true;
    }

    /*----------------------------------------------------------------**/
    function getFeed(bytes memory args) public returns (bool success, address feed) {
        (
            uint256 currency,
            address contract_
        ) = abi.decode(args, (uint256, address));
        
        return (
            true,
            _getFeed(currency, contract_)
        );
    }

    function getFeeds(bytes memory args) public returns (bool success, address[] memory feeds) {
        (
            uint256 currency,
            address[] contracts
        ) = abi.decode(args, (uint256, address[]));

        return (
            true,
            _getFeeds(currency, contracts)
        );
    }

    /*----------------------------------------------------------------**/
    function getPrice(bytes memory args) public returns (bool success, uint256 price) {
        (
            uint256 currency,
            address contract_
        ) = abi.decode(args, (uint256, address));

        return (
            true,
            _getPrice(currency, contract_)
        );   
    }

    function getPrices(bytes memory args) public returns (bool success, uint256[] prices) {
        (
            uint256 currency,
            address[] contracts
        ) = abi.decode(args, (uint256, address[]));

        return (
            true,
            _getPrices(currency, contracts)
        );
    }

}