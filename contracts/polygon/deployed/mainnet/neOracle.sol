
/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neOracle.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;

contract stOracle {
    bytes32 internal constant _ORACLE = keccak256('node.oracle');

    struct StOracle {
        mapping(address => address) contractToPriceFeed;
    }

    function oracle() internal pure virtual returns (StOracle storage s) {
        bytes32 location = _ORACLE;
        assembly {
            s.slot := location
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neOracle.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;

contract stAdmin {
    bytes32 internal constant _ADMIN = keccak256('node.admin');

    struct StAdmin {
        address admin;
    }

    function admin() internal pure virtual returns (StAdmin storage s) {
        bytes32 location = _ADMIN;
        assembly {
            s.slot := location
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neOracle.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.19;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neOracle.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;
////import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
////import 'contracts/polygon/plug-in/storage/stAdmin.sol';
////import 'contracts/polygon/plug-in/storage/stOracle.sol';

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
