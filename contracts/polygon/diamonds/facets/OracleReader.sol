// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/diamonds/facets/Oracle.sol";

interface IOracleReader {
    event OracleChanged(address oldOracle, address newOracle);

    function ____setOracle(address newOracle) external;

    function oracle() external view virtual returns (address);
    function exchange(string memory exchange_) external view returns (address, address);
    function averageValue(string[] memory exchanges, address token0, address token1, uint amount) external view returns (uint);
    function realAverageValue(string[] memory exchanges, address token0, address token1, uint amount) external view returns (uint);
    function value(string memory exchange_, address token0, address token1, uint amount) external view returns (uint);
    function realValue(string memory exchange_, address token0, address token1, uint amount) external view returns (uint);
    function quote(string memory exchange_, address token0, address token1) external view returns (uint);
    function amountOut(string memory exchange_, address token0, address token1) external view returns (uint);
    function amountsOut(string memory exchange_, address[] memory path) external view returns (uint);
}

/// oracle reader will clash with oracle facet
/// built to beam oracle data directly from a diamond with an oracle facet
/// useful so all client contracts do not have to update if any improvements are made to the oracle
/// remove oracle reader to use oracle directly on the diamond
contract OracleReader {
    bytes32 internal constant _ORACLE_READER = keccak256("slot.oracle-reader");

    event OracleChanged(address oldOracle, address newOracle);

    struct OracleReaderStorage {
        address oracle;
    }

    modifier onlySelfOrAdmin() {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        _;
    }

    function oracleReader() internal pure virtual returns (OracleReaderStorage storage s) {
        bytes32 location = _ORACLE_READER;
        assembly {
            s.slot := location
        }
    }

    function ____setOracle(address newOracle) onlySelfOrAdmin() external virtual {
        _setOracle(newOracle);
    }

    function oracle() public view virtual returns (address) {
        return oracleReader().oracle;
    }

    function exchange(string memory exchange_) public view virtual returns (address, address) {
        return IOracle(oracle()).exchange(exchange_);
    }

    function averageValue(string[] memory exchanges, address token0, address token1, uint amount) public view virtual returns (uint) {
        return IOracle(oracle()).averageValue(exchanges, token0, token1, amount);
    }

    function realAverageValue(string[] memory exchanges, address token0, address token1, uint amount) public view virtual returns (uint) {
        return IOracle(oracle()).realAverageValue(exchanges, token0, token1, amount);
    }

    function value(string memory exchange_, address token0, address token1, uint amount) public view virtual returns (uint) {
        return IOracle(oracle()).value(exchange_, token0, token1, amount);
    }

    function realValue(string memory exchange_, address token0, address token1, uint amount) public view virtual returns (uint) {
        return IOracle(oracle()).realValue(exchange_, token0, token1, amount);
    }

    function quote(string memory exchange_, address token0, address token1) public view virtual returns (uint) {
        return IOracle(oracle()).quote(exchange_, token0, token1);
    }

    function amountOut(string memory exchange_, address token0, address token1) public view virtual returns (uint) {
        return IOracle(oracle()).amountOut(exchange_, token0, token1);
    }

    function amountsOut(string memory exchange_, address[] memory path) public view virtual returns (uint) {
        return IOracle(oracle()).amountsOut(exchange_, path);
    }

    function _isSelfOrAdmin() internal view virtual {
        return msg.sender == IConsole(address(this)).admin() || msg.sender == address(this);
    }

    function _setOracle(address newOracle) internal virtual {
        address oldOracle = oracle();
        oracleReader().oracle = newOracle;
        emit OracleChanged(oldOracle, newOracle);
    }
}