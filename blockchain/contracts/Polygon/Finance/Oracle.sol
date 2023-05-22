// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkRequestInterface.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/ChainlinkRegistryInterface.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

interface IOracle {
    function setContractsToFeedsUSD(bytes memory args) external  returns (bool success);
    function setContractsToFeedsETH(bytes memory args) external  returns (bool success);
    function getContractSToFeedsUSD(bytes memory args) external view returns (address[] memory feeds);
    function getContractsToFeedsETH(bytes memory args) external view returns (address[] memory feeds);
    function getContractsToValuesUSD(bytes memory args) external view returns (uint256[] memory values);
    function getContractsToValuesETH(bytes memory args) external view returns (uint256[] memory values);
    function isVerifiedInUSD(bytes memory args) external view returns (bool isVerified);
    function isVerifiedInETH(bytes memory args) external view returns (bool isVerified);
}

contract Oracle is Ownable {
    /** storage */
    mapping(address => address) public contractToFeedUSD;
    mapping(address => address) public contractToFeedETH;

    

    enum currency {
        USD,
        ETH
    }

    constructor() {}
    /*---------------------------------------------------------------- PRIVATE **/
    /** address[] == address[] ??? */
    function _checkAddressArrLenMatch(address[] memory x, address[] memory y) internal pure returns (bool) {
        if (x.length == y.length) {return true;}
        return false;
    }
    /** SINGLE token contract > chainlink feed usd */
    function _setContractToFeedUSD(address contract_, address feed) internal returns (bool) {
        require(contract_ != address(0), "Oracle::_setContractToFeedUSD: token contract is zero address");
        require(feed != address(0), "Oracle::_setContractToFeedUSD: feed contract is zero address");
        contractToFeedUSD[contract_] = feed;
        return true;
    }
    /** MULTIPLE token contracts > chainlink feeds usd */
    function _setContractsToFeedsUSD(address[] memory contracts, address[] memory feeds) internal returns (bool) {
        /** address[] == address[] length ??? */
        require(
            _checkAddressArrLenMatch(contracts, feeds),
            "Oracle::setContractsToFeedsUSD: number of contracts do not match number of feeds"
        );

        for (uint256 i = 0; i < contracts.length; i++) {
            _setContractToFeedUSD(contracts[i], feeds[i]);
            //require(contracts[i] != address(0), "Oracle::_setContractsToFeedsUSD: token contract in batch is zero address");
            //require(feeds[i] != address(0), "Oracle::_setContractsToFeedsUSD: feed contract in batch is zero address");
            //contractToFeedUSD[contracts[i]] = feeds[i];
        }

        return true;
    }
    /** SINGLE token contract > chainlink feed eth */
    function _setContractToFeedETH(address contract_, address feed) internal returns (bool) {
        require(contract_ != address(0), "Oracle::_setContractToFeedETH: token contract is zero address");
        require(feed != address(0), "Oracle::_setContractToFeedETH: feed contract is zero address");
        return true;
    }
    /** MULTIPLE token contracts > chainlink feeds eth */
    function _setContractsToFeedsETH(address[] memory contracts, address[] memory feeds) internal returns (bool) {
        require(
            _checkAddressArrLenMatch(contracts, feeds),
            "Oracle::setContractsToFeedsUSD: number of contracts do not match number of feeds"
        );

        for (uint256 i = 0; i < contracts.length; i++) {
            _setContractToFeedETH(contracts[i], feeds[i]);
            //require(contracts[i] != address(0), "Oracle::_setContractsToFeedsETH: token contract in batch is zero address");
            //require(feeds[i] != address(0), "Oracle::_setContractsToFeedsETH: feed contract in batch is zero address");
            //contractToFeedETH[contracts[i]] = feeds[i];
        }

        return true;
    }
    /** SINGLE token contract > chainlink feed usd */
    function _getContractToFeedUSD(address contract_) internal view returns (address) {
        return contractToFeedUSD[contract_];
    }
    /** MULTIPLE token contracts > chainlink feeds usd */
    function _getContractsToFeedsUSD(address[] memory contracts) internal view returns (address[] memory) {
        address[] memory feeds;
        for (uint256 i = 0; i < contracts.length; i++) {
            feeds[i] = _getContractsToFeedsUSD(contracts[i]);
            //feeds[i] = contractToFeedUSD[contracts[i]];
        }

        return feeds;
    }
    /** SINGLE token contract > chainlink feed eth */
    function _getContractToFeedETH(address contract_) internal returns (address) {
        return contractToFeedETH[contract_];
    }
    /** MULTIPLE token contracts > chainlink feeds eth */
    function _getContractsToFeedsETH(address[] memory contracts) internal view returns (address[] memory) {
        address[] memory feeds;
        for (uint256 i = 0; i < contracts.length; i++) {
            feeds[i] = _getContractToFeedETH(contracts[i]);
            //feeds[i] = contractToFeedETH[contracts[i]];
        }

        return feeds;
    }
    /** SINGLE chainlink feed > price usd */
    function _getFeedToValueUSD(address feed) internal returns (uint256) {
        AggregatorV3Interface aggregator = AggregatorV3Interface(feed);
        (, int256 price, , , ) = aggregator.latestRoundData();
        return uint256(price);
    }
    /** MULTIPLE chainlink feeds > prices usd */
    function _getFeedsToValuesUSD(address[] memory feeds) internal view returns (uint256[] memory) {
        uint256[] memory values;
        for (uint256 i = 0; i < feeds.length; i++) {
            values[i] = _getFeedToValueUSD(feeds[i]);
            //AggregatorV3Interface aggregator = AggregatorV3Interface(feeds[i]);
            //(, int256 price, , , ) = aggregator.latestRoundData();
            //values[i] = uint256(price);
        }

        return values;
    }
    /** SINGLE chainlink feed > price usd */
    function _getFeedToValueETH(address feed) internal returns (uint256) {
        AggregatorV3Interface aggregator = AggregatorV3Interface(feed);
        (, int256 price, , , ) = aggregator.latestRoundData();
        return uint256(price);
    }
    /** MULTIPLE chainlink feeds > prices eth */
    function _getFeedsToValuesETH(address[] memory feeds) internal view returns (uint256[] memory) {
        uint256[] memory values;
        for (uint256 i = 0; i < feeds.length; i++) {
            values[i] = _getFeedToValueETH(feeds[i]);
            //AggregatorV3Interface aggregator = AggregatorV3Interface(feeds[i]);
            //(, int256 price, , , ) = aggregator.latestRoundData();
            //values[i] = uint256(price);
        }

        return values;
    }

    function _isVerified(address contract_) internal view returns (bool, bool) {
        
        address feedForUSD = _getContractToFeedUSD(contract_);
        address feedForETH = _getContractToFeedETH(contract_);
        bool isVerifiedForUSD;
        bool isVerifiedForETH;
        if (feedForUSD != address(0)) {
            /** check for abnormal pricing */
            if (_getFeedToValueUSD(feedForUSD) <= 0) {isVerifiedForUSD = false;}
            else {isVerifiedForUSD = true;}
        }

        if (feedForETH != address(0)) {
            /** check for abnormal pricing */
            if (_getFeedToValueUSD(feedForETH) <= 0) {isVerifiedForETH = false;}
            else {isVerifiedForETH = true;}
        }

        return (isVerifiedForUSD, isVerifiedForETH);
    }

    /*---------------------------------------------------------------- OWNER COMMANDS **/
    /** SINGLE token contract > chainlink feed usd */
    function setContractToFeedUSD(bytes memory args) public onlyOwner returns (bool) {
        (address contract_, address feed) = abi.decode(args, (address, address));
        _setContractToFeedUSD(contract_, feed);
        return true;
    }
    /** MULTPLE token contracts > chainlink feeds usd */
    function setContractsToFeedsUSD(bytes memory args) public onlyOwner returns (bool) {
        (
            address[] memory contracts,
            address[] memory feeds
        ) = abi.decode(
            args,
            (
                address[],
                address[]
            )
        );

        _setContractsToFeedsUSD(contracts, feeds);

        return true;
    }
    /** SINGLE token contract > chainlink feed eth */
    function setContractToFeedETH(bytes memory args) public onlyOwner returns (bool) {
        (address contract_, address feed) = abi.decode(args, (address, address));
        _setContractToFeedETH(contract_, feed);
        return true;
    }
    /** MULTIPLE token contracts > chainlink feeds eth */
    function setContractsToFeedsETH(bytes memory args) public onlyOwner returns (bool) {
        (
            address[] memory contracts,
            address[] memory feeds
        ) = abi.decode(
            args,
            (
                address[],
                address[]
            )
        );

        _setContractsToFeedsETH(contracts, feeds);

        return true;
    }

    /*---------------------------------------------------------------- PUBLIC **/
    function getContractToValueUSD(bytes memory args) public view returns (uint256) {
        address contract_ = abi.decode(args, (address));
        return _getFeedToValueUSD(
            _getContractToFeedUSD(
                contract_
            )
        );
    }

    function getContractToValueETH(bytes memory args) public view returns (uint256) {
        address contract_  = abi.decode(args, (address));
        return _getFeedToValueETH(
            _getContractFeedETH(
                contract_
            )
        );
    }

    function isVerifiedInUSD(bytes memory args) public view returns (bool) {
        address contract_ = abi.decode(args, (address));
        address feed = contractToFeedUSD[contract_];

        if (feed != address(0)) {
            /** check for abnormal price */
            address[] memory feeds;
            feeds[0] = feed;
            uint256[] memory prices = _getFeedsToValuesUSD(feeds);
            if (prices[0] <= 0) {return false;}

            return true;
        }

        return false;
    }

    function isVerifiedInETH(bytes memory args) public view returns (bool) {
        address contract_ = abi.decode(args, (address));
        address feed = contractToFeedETH[contract_];
        
        if (feed != address(0)) {
            /** check for abnormal price */
            address[] memory feeds;
            feeds[0] = feed;
            uint256[] memory prices = _getFeedsToValuesETH(feeds);
            if (prices[0] <= 0) {return false;}
            
            return true;
        }

        return false;
    }

}