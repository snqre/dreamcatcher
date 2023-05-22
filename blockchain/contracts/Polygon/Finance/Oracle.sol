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

    constructor() {}
    /*---------------------------------------------------------------- PRIVATE **/
    /** address[] == address[] ??? */
    function _checkAddressArrLenMatch(address[] memory x, address[] memory y) internal pure returns (bool) {
        if (x.length == y.length) {return true;}
        return false;
    }
    /** token contracts > chainlink feeds usd */
    function _setContractsToFeedsUSD(address[] memory contracts, address[] memory feeds) internal returns (bool) {
        /** address[] == address[] length ??? */
        require(
            _checkAddressArrLenMatch(contracts, feeds),
            "Oracle::setContractsToFeedsUSD: number of contracts do not match number of feeds"
        );

        for (uint256 i = 0; i < contracts.length; i++) {
            require(contracts[i] != address(0), "Oracle::_setContractsToFeedsUSD: token contract in batch is zero address");
            require(feeds[i] != address(0), "Oracle::_setContractsToFeedsUSD: feed contract in batch is zero address");
            contractToFeedUSD[contracts[i]] = feeds[i];
        }

        return true;
    }
    /** token contracts > chainlink feeds eth */
    function _setContractsToFeedsETH(address[] memory contracts, address[] memory feeds) internal returns (bool) {
        require(
            _checkAddressArrLenMatch(contracts, feeds),
            "Oracle::setContractsToFeedsUSD: number of contracts do not match number of feeds"
        );

        for (uint256 i = 0; i < contracts.length; i++) {
            require(contracts[i] != address(0), "Oracle::_setContractsToFeedsETH: token contract in batch is zero address");
            require(feeds[i] != address(0), "Oracle::_setContractsToFeedsETH: feed contract in batch is zero address");
            contractToFeedETH[contracts[i]] = feeds[i];
        }

        return true;
    }
    /** token contracts > chainlink feeds usd */
    function _getContractsToFeedsUSD(address[] memory contracts) internal view returns (address[] memory) {
        address[] memory feeds;
        for (uint256 i = 0; i < contracts.length; i++) {
            feeds[i] = contractToFeedUSD[contracts[i]];
        }

        return feeds;
    }
    /** token contracts > chainlink feeds eth */
    function _getContractsToFeedsETH(address[] memory contracts) internal view returns (address[] memory) {
        address[] memory feeds;
        for (uint256 i = 0; i < contracts.length; i++) {
            feeds[i] = contractToFeedETH[contracts[i]];
        }

        return feeds;
    }

    /** chainlink feeds > prices usd */
    function _getFeedsToValuesUSD(address[] memory feeds) internal view returns (uint256[] memory) {
        uint256[] memory values;
        for (uint256 i = 0; i < feeds.length; i++) {
            AggregatorV3Interface aggregator = AggregatorV3Interface(feeds[i]);
            (, int256 price, , , ) = aggregator.latestRoundData();
            
            values[i] = uint256(price);
        }

        return values;
    }
    /** chainlink feeds > prices eth */
    function _getFeedsToValuesETH(address[] memory feeds) internal view returns (uint256[] memory) {
        uint256[] memory values;
        for (uint256 i = 0; i < feeds.length; i++) {
            AggregatorV3Interface aggregator = AggregatorV3Interface(feeds[i]);
            (, int256 price, , , ) = aggregator.latestRoundData();

            values[i] = uint256(price);
        }

        return values;
    }

    /*---------------------------------------------------------------- OWNER COMMANDS **/
    /** token contracts > chainlink feeds usd */
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
    /** token contracts > chainlink feeds eth */
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
    /** token contracts to chainlink feeds usd */
    function getContractsToFeedsUSD(bytes memory args) public view returns (address[] memory) {
        address[] memory contracts = abi.decode(args, (address[]));
        address[] memory feeds = _getContractsToFeedsUSD(contracts);
        return feeds;
    }
    /** token contracts to chainlink feeds eth */
    function getContractsToFeedsETH(bytes memory args) public view returns (address[] memory) {
        address[] memory contracts = abi.decode(args, (address[]));
        address[] memory feeds = _getContractsToFeedsETH(contracts);
        return feeds;
    }
    /** token contracts > token prices in usd */
    function getContractsToValuesUSD(bytes memory args) public view returns (uint256[] memory) {
        address[] memory contracts = abi.decode(args, (address[]));
        address[] memory feeds = _getContractsToFeedsUSD(contracts);
        return  _getFeedsToValuesUSD(feeds);
    }
    /** token contracts > token prices in eth */
    function getContractsToValuesETH(bytes memory args) public view returns (uint256[] memory) {
        address[] memory contracts = abi.decode(args, (address[]));
        address[] memory feeds = _getContractsToFeedsETH(contracts);
        return _getFeedsToValuesETH(feeds);
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