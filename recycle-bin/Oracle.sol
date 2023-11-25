// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/solidstate/Api3Adaptor.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";

interface IOracle {
    event AdaptorDeployed(address token, address denominatorToken, uint8 decimals_, address api3Address);

    function ____deployAdaptor(address token, address denominatorToken, uint8 decimals_, address api3Address) external;

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

contract Oracle {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 internal constant _ORACLE = keccak256("slot.oracle");

    event AdaptorDeployed(address token, address denominatorToken, uint8 decimals_, address api3Address);

    struct OracleStorage {
        mapping(address => address) adaptor;
    }

    function oracle() internal pure virtual returns (OracleStorage storage s) {
        bytes32 location = _ORACLE;
        assembly {
            s.slot := location
        }
    }

    ///

    function ____deployAdaptor(address token, address denominatorToken, uint8 decimals_, address api3Address) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        IApi3Adaptor newAdaptor = IApi3Adaptor(new Api3Adaptor());
        IToken token_ = IToken(token);
        IToken denominatorToken_ = IToken(denominatorToken);
        newAdaptor.setSymbolA = token_.symbol();
        newAdaptor.setSymbolB = denominatorToken_.symbol();
        newAdaptor.setDecimals(decimals_);
        newAdaptor.setApi3Server(api3Address);
        newAdaptor.start();
        oracle().adaptor[token] = address(newAdaptor);
        emit AdaptorDeployed(token, denominatorToken, decimals_, api3Address);
    }

    ///

    function adaptor(address token) public view virtual returns (address) {
        return oracle().api3Adaptor[feedId];
    }

    function hasAdaptor(address token) public view virtual returns (bool) {
        return adaptor(token) != address(0);
    }

    ///

    function symbolA(address token) public view virtual returns (string memory) {
        return IApi3Adaptor(adaptor(token)).symbolA();
    }

    function symbolB(address token) public view virtual returns (string memory) {
        return IApi3Adaptor(adaptor(token)).symbolB();
    }

    /// divide the price by this to get the human readable price
    function decimals(address token) public view virtual returns (uint8) {
        return IApi3Adaptor(adaptor(token)).decimals();
    }

    ///

    function price(address token) public view virtual returns (uint) {
        return IApi3Adaptor(adaptor(token)).price();
    }

    function timestamp(address token) public view virtual returns (uint) {
        return IApi3Adaptor(adaptor(token)).timestamp();
    }

    ///

    function isWithinTheLastHour(address token) public view virtual returns (bool) {
        return IApi3Adaptor(adaptor(token)).isWithinTheLastHour();
    }

    function isWithinTheLastDay(address token) public view virtual returns (bool) {
        return IApi3Adaptor(adaptor(token)).isWithinTheLastDay();
    }

    function isWithinTheLastWeek(address token) public view virtual returns (bool) {
        return IApi3Adaptor(adaptor(token)).isWithinTheLastWeek();
    }

    function isWithinTheLastMonth(address token) public view virtual returns (bool) {
        return IApi3Adaptor(adaptor(token)).isWithinTheLastMonth();
    }

    ///

    function _isSelfOrAdmin() internal view virtual returns (bool) {
        return msg.sender == IConsole(address(this)).admin() || msg.sender == address(this);
    }
}