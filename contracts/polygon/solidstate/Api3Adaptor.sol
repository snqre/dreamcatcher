// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/libraries/Finance.sol";

interface IDapiProxy {
    function api3ServerV1() external view returns (address);
    function dapiNameHash() external view returns (bytes32);
    function read() external view returns (int224, uint32);
}

interface IApi3Adaptor {
    using Finance for uint;

    event SymbolAChanged(string oldSymbol, string newSymbol);
    event SymbolBChanged(string oldSymbol, string newSymbol);
    event Api3ServerChanged(address oldAddress, address newAddress);
    event SetUp(string symbolA, string symbolB, address api3Server);

    function symbolA() external view returns (string memory);
    function symbolB() external view returns (string memory);
    function decimals() external view returns (uint8);

    function api3Server() external view returns (address);

    function ready() external view returns (bool);

    function price() external view returns (uint);
    function timestamp() external view returns (uint);

    function time() external view returns (uint);

    function isWithinTheLastHour() external view returns (bool);
    function isWithinTheLastDay() external view returns (bool);
    function isWithinTheLastWeek() external view returns (bool);
    function isWithinTheLastMonth() external view returns (bool);

    function start() external;
    function setSymbolA(string memory newSymbol) external;
    function setSymbolB(string memory newSymbol) external;
    function setDecimals(uint8 newDecimals) external;
    function setApi3Server(address newAddress) external;

    function owner() external view returns (address);

    function renounceOwnership() external;
    function transferOwnership(address newOwner) external;
}

contract Api3Adaptor is Ownable {


    string private _symbolA;
    string private _symbolB;
    uint8 private _decimals;
    address private _api3Server;
    bool private _ready;

    event SymbolAChanged(string oldSymbol, string newSymbol);
    event SymbolBChanged(string oldSymbol, string newSymbol);
    event Api3ServerChanged(address oldAddress, address newAddress);
    event DecimalsChanged(uint oldDecimals, uint newDecimals);
    event SetUp(string symbolA, string symbolB, address api3Server);

    constructor() Ownable(msg.sender) {}

    function symbolA() public view virtual returns (string memory) {
        require(ready(), "!ready");
        return _symbolA;
    }

    function symbolB() public view virtual returns (string memory) {
        require(ready(), "!ready");
        return _symbolB;
    }

    /// divide by this number
    function decimals() public view virtual returns (uint8) {
        require(ready(), "!ready");
        return _decimals;
    }

    ///

    function api3Server() public view virtual returns (address) {
        require(ready(), "!ready");
        return _api3Server;
    }

    ///

    function ready() public view virtual returns (bool) {
        return _ready;
    }

    ///

    /// price as 10**18 value
    function price() public view virtual returns (uint) {
        require(ready(), "!ready");
        (int224 price,) = IDapiProxy(api3Server()).read();
        /// converting whatever non standard into 18 decimals value
        return uint(uint224(price)).computeAsStandardValue(decimals());
    }

    /// get timestamp of the when the last price was pushed
    function timestamp() public view virtual returns (uint) {
        require(ready(), "!ready");
        (, uint32 timestamp) = IDapiProxy(api3Server()).read();
        return uint(timestamp);
    }

    ///

    function time() public view virtual returns (uint) {
        return block.timestamp;
    }

    ///

    function isWithinTheLastHour() public view virtual returns (bool) {
        require(ready(), "!ready");
        if (timestamp() >= time() - 3600 seconds) {
            return true;
        }
        return false;
    }

    function isWithinTheLastDay() public view virtual returns (bool) {
        require(ready(), "!ready");
        if (timestamp() >= time() - 86400 seconds) {
            return true;
        }
        return false;
    }

    function isWithinTheLastWeek() public view virtual returns (bool) {
        require(ready(), "!ready");
        if (timestamp() >= time() - 604800 seconds) {
            return true;
        }
        return false;
    }

    function isWithinTheLastMonth() public view virtual returns (bool) {
        require(ready(), "!ready");
        if (timestamp() >= time() - 2419200 seconds) {
            return true;
        }
        return false;
    }

    ///

    function start() onlyOwner public virtual {
        require(!ready(), "ready");
        _ready = true;
        emit SetUp(symbolA(), symbolB(), api3Server());
    }

    function setSymbolA(string memory newSymbol) onlyOwner public virtual {
        require(!ready(), "ready");
        string memory oldSymbol = symbolA();
        _symbolA = newSymbol;
        emit SymbolAChanged(oldSymbol, newSymbol);
    }

    function setSymbolB(string memory newSymbol) onlyOwner public virtual {
        require(!ready(), "ready");
        string memory oldSymbol = symbolB();
        _symbolB = newSymbol;
        emit SymbolBChanged(oldSymbol, newSymbol);
    }

    function setDecimals(uint8 newDecimals) onlyOwner public virtual {
        require(!ready(), "ready");
        uint8 oldDecimals = decimals();
        _decimals = newDecimals;
        emit DecimalsChanged(oldDecimals, newDecimals);
    }

    function setApi3Server(address newAddress) onlyOwner public virtual {
        require(!ready(), "ready");
        address oldAddress = api3Server();
        _api3Server = newAddress;
        emit Api3ServerChanged(oldAddress, newAddress);
    }
}