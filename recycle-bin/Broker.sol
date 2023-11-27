// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/diamonds/facets/OracleReader.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";
import "contracts/polygon/libraries/Finance.sol";

contract Broker is Ownable {
    using Finance for uint;

    address private _oracle;
    uint private _collateral;
    uint private _deposit;
    uint private _withdraw;
    uint private _slippageThreshold;
    uint private _startTimestamp;
    uint private _duration;
    bool private _success;
    bool private _ready;

    constructor() Ownable(msg.sender) {}

    function oracle() public view virtual returns (address) {
        return _oracle;
    }

    ///

    function adaptor(address token) public view virtual returns (address) {
        return IOracleReader(oracle()).adaptor(token);
    }

    function hasAdaptor(address token) public view virtual returns (bool) {
        return IOracleReader(oracle()).hasAdaptor(token);
    }

    ///

    function symbolA(address token) public view virtual returns (string memory) {
        return IOracleReader(oracle()).symbolA(token);
    }

    function symbolB(address token) public view virtual returns (string memory) {
        return IOracleReader(oracle()).symbolB(token);
    }

    /// divide the price by this to get the human readable price
    function decimals(address token) public view virtual returns (uint8) {
        return IOracleReader(oracle()).decimals(token);
    }

    ///

    function price(address token) public view virtual returns (uint) {
        return IOracleReader(oracle()).price(token);
    }

    function timestamp(address token) public view virtual returns (uint) {
        return IOracleReader(oracle()).timestamp(token);
    }

    ///

    function isWithinTheLastHour(address token) public view virtual returns (bool) {
        return IOracleReader(oracle()).isWithinTheLastHour(token);
    }

    function isWithinTheLastDay(address token) public view virtual returns (bool) {
        return IOracleReader(oracle()).isWithinTheLastDay(token);
    }

    function isWithinTheLastWeek(address token) public view virtual returns (bool) {
        return IOracleReader(oracle()).isWithinTheLastWeek(token);
    }

    function isWithinTheLastMonth(address token) public view virtual returns (bool) {
        return IOracleReader(oracle()).isWithinTheLastMonth(token);
    }

    ///

    function deposit() public view virtual returns (uint) {
        return _deposit;
    }

    function withdraw() public view virtual returns (uint) {
        return _withdraw;
    }

    ///

    function slippageThreshold() public view virtual returns (uint) {
        return _slippageThreshold;
    }

    function slippage() public view virtual returns (uint) {
        return withdraw() - deposit();
    }

    ///

    function startTimestamp() public view virtual returns (uint) {
        return _startTimestamp;
    }

    function duration() public view virtual returns (uint) {
        return _duration;
    }

    function time() public view virtual returns (uint) {
        return block.timestamp;
    }

    function begun() public view virtual returns (bool) {
        return time() >= startTimestamp() && ready();
    }

    function ended() public view virtual returns (bool) {
        return time() >= startTimestamp() + duration() && ready();
    }

    function isInSession() public view virtual returns (bool) {
        return begun() && !ended() && ready();
    }

    ///

    function success() public view virtual returns (bool) {
        return _success;
    }

    ///

    function ready() public view virtual returns (bool) {
        return _ready;
    }

    ///

    function conditionsHaveBeenMet() public view virtual returns (bool) {
        if (!success()) {
            return isInSession() && slippage() <= slippageThreshold();
        }
        return success();
    }

    ///

    function deposit(address tokenIn, uint amountIn) public virtual {
        IToken token = IToken(tokenIn);
        require(hasAdaptor(tokenIn), "!hasAdaptor");
        require(!_priceIsZero(tokenIn), "_priceIsZero");
        token.transferFrom(msg.sender, address(this), amountIn);
        amountIn = amountIn.computeAsNativeValue(token.decimals());
        uint price_ = price(tokenIn);
        price_ = price_.computeAsNativeValue(decimals(tokenIn));
        _deposit += price_ * amountIn;
    }

    ///

    function _priceIsZero(address tokenIn) public virtual {
        uint price_ = price(tokenIn);
        uint price_ = price_.computeAsNativeValue(decimals(tokenIn));
        return price_ == 0;
    }
}