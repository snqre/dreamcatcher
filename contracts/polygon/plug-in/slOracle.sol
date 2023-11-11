// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IEACAggregatorProxy {
    function latestAnswer() external view returns (uint);

    function latestTimestamp() external view returns (uint);
}

//0xc907E116054Ad103354f2D350FD2514433D57F6f

/**
* @dev The sl oracle implementation makes use of both api3 and chainlink
*      oracles to get the price of supported tokens.
 */
contract slOracle {
    
    function _assignTokenToFeed(address token, address feed) internal virtual {

    }

    function ____chainlinkTokenToFeedMapping(address token) internal pure virtual returns (bytes32) {
        return keccak256(abi.encode('CHAINLINK_TOKEN_TO_FEED_MAPPING', token));
    }

}