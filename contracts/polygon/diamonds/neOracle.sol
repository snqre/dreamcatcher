// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
import 'contracts/polygon/plug-in/storage/stAdmin.sol';
import 'contracts/polygon/plug-in/storage/stOracle.sol';

interface IEACAggregatorProxy {
    function latestAnswer() external view returns (uint);
    function latestTimestamp() external view returns (uint);
}

contract neOracle is Context, stOracle, stAdmin {
    event TokenContractPriceFeedChanged(address token, address oldPriceFeed, address newPriceFeed); 

    function getPriceFeedLatestAnswer(address token) public view virtual returns (uint) {
        address priceFeed = getAssignedPriceFeed(token);
        require(priceFeed != address(0), 'neOracle: unassigned token');
        return IEACAggregatorProxy(priceFeed).latestAnswer();
    }

    function getPriceFeedLatestTimestamp(address token) public view virtual returns (uint) {
        address priceFeed = getAssignedPriceFeed(token);
        require(priceFeed != address(0), 'neOracle: unassigned token');
        return IEACAggregatorProxy(priceFeed).latestTimestamp();
    }

    function getAssignedPriceFeed(address token) public view virtual returns (address) {
        return oracle().contractToPriceFeed[token];
    }

    function assignOracleTokenContractToPriceFeed(address token, address newPriceFeed) public virtual {
        require(_msgSender() == admin().admin, 'neOracle: only admin');
        address oldPriceFeed = oracle().contractToPriceFeed[token];
        oracle().contractToPriceFeed[token] = newPriceFeed;
        emit TokenContractPriceFeedChanged(token, oldPriceFeed, newPriceFeed);
    }
}