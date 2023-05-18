// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkRequestInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkRegistryInterface.sol";

import "dreamcatcher/dream_standard.sol";

contract Terminal is DreamStandard {

    /**
    * owner: dreamcatcher
    * nativeToken: $DREAM
    * vault: where we send gas
    * gas: cost of using out terminal
     */

    address owner;
    address nativeToken;
    address vault;
    uint256 gas;

    mapping(address => Account) private accounts;

    // contractOfToken > priceFeedOfTokenInUSD
    mapping(string => address) private symbolOfTokenToPriceFeedOfTokenInUSD;
    mapping(address => address) private contractOfTokenToPriceFeedOfTokenInUSD;
    mapping(address => address) private contractOfTokenToPriceFeedOfTokenInETH;


    modifier onlyOwner() {
        accounts
        require(msg.sender == owner);
        _;
    }


    modifier monetize() {
        if (msg.sender != owner) {
            IERC20(nativeToken).transferFrom(msg.sender, dreamcatcher, gas);
        }
        _;
    }

    constructor() {}


    /** get price from price feed  */
    function getPriceFromPriceFeed_(address _priceFeed) private view returns (uint256) {
        AggregatorV3Interface aggregator = AggregatorV3Interface(_priceFeed);
        (uint80, _price, uint, uint, uint80) = aggregator.latestRoundData();
        require(_price >= 0);
        return uint256(_price);
    }
    

    /** set contracts to price feeds for usd pair */
    function setContractsToPriceFeedsForUSD(
        address[] _tokens,
        address[] _priceFeeds
    ) public onlyOwner returns (bool _success) {
        require(_tokens.length == _priceFeeds.length, "array lengths not matching");
        for (uint256 _i = 0; _i < _tokens.length; _i++) {contractOfTokenToPriceFeedOfTokenInUSD[_tokens[_i]] = _priceFeeds[_i];}
        return true;
    }


    /** get price from erc20 contract in usd pair */
    function getPriceFromERC20ContractInUSD(address _ERC20Contract) private view monetize returns (uint256) {
        address _priceFeed = contractOfTokenToPriceFeedOfTokenInUSD[_ERC20Contract];
        require(_priceFeed != 0, "unable to locate price feed");
        require(_priceFeed >= 0, "unexpected reading");
        return getPriceFromPriceFeed_(_priceFeed);
    }

}