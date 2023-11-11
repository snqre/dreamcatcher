// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
import 'contracts/polygon/plug-in/storage/stAdmin.sol';
import 'contracts/polygon/plug-in/storage/stOracle.sol';

contract neOracle is Context, stOracle, stAdmin {
    event TokenContractPriceFeedChanged(address token, address oldPriceFeed, address newPriceFeed); 
    
    function assignOracleTokenContractToPriceFeed(address token, address newPriceFeed) public virtual {
        require(_msgSender() == admin().admin, 'neOracle: only admin');
        address oldPriceFeed = oracle().contractToPriceFeed[token];
        oracle().contractToPriceFeed[token] = newPriceFeed;
        emit TokenContractPriceFeedChanged(token, oldPriceFeed, newPriceFeed);
    }
}