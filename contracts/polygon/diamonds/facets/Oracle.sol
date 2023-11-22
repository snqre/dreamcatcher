// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/diamonds/facets/Console.sol";

contract Oracle {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _ORACLE = keccak256("slot.oracle");

    event FeedChanged(address token, address oldFeed, address newFeed);

    struct OracleStorage {
        IConsole console;
        mapping(address => address) feed;
    }

    function oracle() internal pure virtual returns (OracleStorage storage s) {
        bytes32 location = _ORACLE;
        assembly {
            s.slot := location
        }
    }

    ///

    function __oracle__() public virtual {
        oracle().console = IConsole(address(this));
    }

    ///

    function ____setFeed(address token, address newFeed) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        address oldFeed = feed(token);
        oracle().feed[token] = newFeed;
        emit FeedChanged(token, oldFeed, newFeed);
    }

    ///

    function feed(address token) public view virtual returns (address) {
        return oracle().feed[token];
    }

    ///

    function _isSelfOrAdmin() internal view virtual returns (bool) {
        return msg.sender == oracle().console.admin();
    }
}