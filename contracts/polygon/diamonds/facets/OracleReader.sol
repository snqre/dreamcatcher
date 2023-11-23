// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/diamonds/facets/Oracle.sol";

interface IOracleReader {
    event OracleChanged(address oldOracle, address newOracle);

    function ____setOracle(address newOracle) external;

    function oracle() external view returns (address);

    function adaptor(address token) external view returns (address);
    function hasAdaptor(address token) external view returns (bool);

    function symbolA(address token) external view returns (string memory);
    function symbolB(address token) external view returns (string memory);
    function decimals(address token) external view returns (uint8);

    function price(address token) external view returns (uint);
    function timestamp(address token) external view returns (uint);

    function isWithinTheLastHour(address token) external view returns (bool);
    function isWithinTheLastDay(address token) external view returns (bool);
    function isWithinTheLastWeek(address token) external view returns (bool);
    function isWithinTheLastMonth(address token) external view returns (bool);
}

contract OracleReader {
    bytes32 internal constant _ORACLE_READER = keccak256("slot.oracle-reader");

    event OracleChanged(address oldOracle, address newOracle);

    struct OracleReaderStorage {
        address oracle;
    }

    function oracleReader() internal pure virtual returns (OracleReaderStorage storage s) {
        bytes32 location = _ORACLE_READER;
        assembly {
            s.slot := location
        }
    }

    ///

    function ____setOracle(address newOracle) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        address oldOracle = oracle();
        oracleReader().oracle = newOracle;
        emit OracleChanged(oldOracle, newOracle);
    }

    ///

    /// this does not conflict with oracle because this is public and the other is internal on another facet
    function oracle() public view virtual returns (address) {
        return oracleReader().oracle;
    }

    ///

    /// the following will conflict with the oracle facet

    function adaptor(address token) public view virtual returns (address) {
        return IOracle(oracle()).adaptor(token);
    }

    function hasAdaptor(address token) public view virtual returns (bool) {
        return IOracle(oracle()).hasAdaptor(token);
    }

    ///

    /// the following will conflict with the oracle facet

    function symbolA(address token) public view virtual returns (string memory) {
        return IOracle(oracle()).symbolA(token);
    }

    function symbolB(address token) public view virtual returns (string memory) {
        return IOracle(oracle()).symbolB(token);
    }

    /// divide the price by this to get the human readable price
    function decimals(address token) public view virtual returns (uint8) {
        return IOracle(oracle()).decimals(token);
    }

    ///

    /// the following will conflict with the oracle facet

    function price(address token) public view virtual returns (uint) {
        return IOracle(oracle()).price(token);
    }

    function timestamp(address token) public view virtual returns (uint) {
        return IOracle(oracle()).timestamp(token);
    }

    ///

    /// the following will conflict with the oracle facet

    function isWithinTheLastHour(address token) public view virtual returns (bool) {
        return IOracle(oracle()).isWithinTheLastHour(token);
    }

    function isWithinTheLastDay(address token) public view virtual returns (bool) {
        return IOracle(oracle()).isWithinTheLastDay(token);
    }

    function isWithinTheLastWeek(address token) public view virtual returns (bool) {
        return IOracle(oracle()).isWithinTheLastWeek(token);
    }

    function isWithinTheLastMonth(address token) public view virtual returns (bool) {
        return IOracle(oracle()).isWithinTheLastMonth(token);
    }

    ///

    function _isSelfOrAdmin() internal view virtual returns (bool) {
        return msg.sender == IConsole(address(this)).admin() || msg.sender == address(this);
    }
}