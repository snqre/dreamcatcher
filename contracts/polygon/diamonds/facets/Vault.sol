// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/Console.sol";
import "contracts/polygon/diamonds/facets/OracleReader.sol";
import "contracts/polygon/solidstate/ERC20/PoolToken.sol";
import "contracts/polygon/libraries/Finance.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/solidstate/ERC20/Token.sol";

interface IVault { /// in and out
    event SharesTokenDeployed(address newToken);
    event Deposit(address tokenIn, uint amountIn, uint sharesOut);
    event Withdraw(uint sharesIn); /// scrapped the idea of arrays to display tokens and amounts out because would be too complicated

    function ____deploySharesToken(string memory name, string memory symbol, uint initMint) external;

    function shares() external view returns (address);
    function sharesDeployed() external view returns (bool);

    function onHand(uint assetId) external view returns (address);
    function onHand() external view returns (address[] memory);
    function onHandLength() external view returns (uint);

    function deposit(address tokenIn, uint amountIn) external;
    function withdraw(uint amountIn) external;
}

/// ____deploySharesToken first
/// vault closed beta
contract Vault {
    using Finance for uint;

    bytes32 internal constant _VAULT = keccak256("slot.vault");

    event SharesTokenDeployed(address newToken);
    event Deposit(address tokenIn, uint amountIn, uint sharesOut);
    event Withdraw(uint sharesIn); /// scrapped the idea of arrays to display tokens and amounts out because would be too complicated

    struct VaultStorage {
        address shares;
        bool sharesDeployed;
        /// core vulnerabilities include having too many types of tokens in the vault may cause expensive gas prices
        EnumerableSet.AddressSet onHand; /// any tokens that are owned by the vault
    }

    function vault() internal pure virtual returns (VaultStorage storage s) {
        bytes32 location = _VAULT;
        assembly {
            s.slot := location
        }
    }

    ///

    /// must be done to activate the vault
    function ____deploySharesToken(string memory name, string memory symbol, uint initMint) external virtual {
        require(_isSelfOrAdmin(), "!_isSelfOrAdmin");
        require(!sharesDeployed(), "sharesDeployed");
        /// require at least an amount in the vault that cant be removed, and an amount of supply in the vault to do math
        require(msg.value >= 500000, "insufficient value to mint");
        vault().shares = new PoolToken(name, symbol, initMint); /// initial supply as initMint * 10**18
        vault().sharesDeployed = true;
        emit SharesTokenDeployed(shares());
    }

    ///

    /// the address of the pool token
    function shares() public view virtual returns (address) {
        return vault().shares;
    }

    function sharesDeployed() public view virtual returns (bool) {
        return vault().sharesDeployed;
    }

    ///
    
    function onHand(uint assetId) public view virtual returns (address) {
        return vault().onHand.at(assetId);
    }

    function onHand() public view virtual returns (address[] memory) {
        return vault().onHand.values();
    }

    function onHandLength() public view virtual returns (uint) {
        return vault().onHand.length();
    }

    ///

    /// deposit any token that has an adaptor (oracle) and that the fund manager wants in
    function deposit(address tokenIn, uint amountIn) public virtual {
        require(sharesDeployed(), "!sharesDeployed");
        require(_hasEnoughTokens(tokenIn, amountIn), "!_hasEnoughTokens");
        require(_hasAdaptor(tokenIn), "!_hasAdaptor");
        IToken tokenInInterface = IToken(tokenIn);
        IPoolToken sharesInterface = IPoolToken(shares());
        tokenInInterface.transferFrom(msg.sender, address(this), amountIn);
        amountIn.computeAsStandardValue(tokenInInterface.decimals()); /// amountIn must not be zero
        uint price = _price(tokenIn);
        uint valueIn = price * (amountIn * 10**18);
        valueIn /= 10**18;
        uint amountToMint = valueIn.computeSharesToMint(assets(), sharesInterface.totalSupply()); /// total supply must never be zero NEVER
        /// shares minted to caller
        sharesInterface.mint(msg.sender, amountToMint);
        emit Deposit(tokenIn, amountIn, amountToMint);
    }

    /// burn shares to get portion of tokens in vault
    function withdraw(uint amountIn) public virtual {
        require(sharesDeployed(), "!sharesDeployed");
        require(_hasEnoughShares(amountIn), "!_hasEnoughShares");
        IPoolToken shares = IPoolToken(shares());
        /// portion of the total supply of shares
        uint portion = (amountIn * 10000) / shares.totalSupply(); /// by using supply theres not need to calculate prices or using oracle for withdrawals
        shares.burnFrom(msg.sender, amountIn);
        address[] memory tokensOut;
        uint[] memory amountsOut;
        tokensOut = new address[](onHandLength());
        for (uint i = 0; i < onHandLength(); i++) {
            /// returns the portion in kind back to the caller
            _returnPortionOfAsset(onHand(i), portion);
        }
        emit Withdraw(amountIn);
    }

    ///

    function _isSelfOrAdmin() internal view virtual returns (bool) {
        return msg.sender == IConsole(address(this)).admin || msg.sender == address(this);
    }

    ///

    function _hasEnoughShares(uint amountIn) internal view virtual returns (bool) {
        return IPoolToken(shares()).balanceOf(msg.sender) >= amountIn;
    }

    function _hasEnoughTokens(address tokenIn, uint amountIn) internal view virtual returns (bool) {
        return IToken(tokenIn).balanceOf(msg.sender) >= amountIn;
    }

    ///

    /// send the portion (basis points) of assets back to the caller
    function _returnPortionOfAsset(address token, uint portion) internal virtual {
        IToken tokenOut = IToken(token);
        uint amount = tokenOut.balanceOf(address(this));
        uint amountToSend = (amount * portion) / 10000;
        tokenOut.transfer(msg.sender, amountToSend);
    }

    ///

    function _hasEnoughBalance(address token, uint amount) internal view virtual returns (bool) {
        return IToken(token).balanceOf(address(this)) >= amount;
    }

    ///

    function _adaptor(address token) internal view virtual returns (address) {
        return IOracleReader(address(this)).adaptor(token);
    }

    function _hasAdaptor(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).hasAdaptor(token);
    }

    ///

    function _symbolA(address token) internal view virtual returns (string memory) {
        return IOracleReader(address(this)).symbolA(token);
    }

    function _symbolB(address token) internal view virtual returns (string memory) {
        return IOracleReader(address(this)).symbolB(token);
    }

    function _decimals(address token) internal view virtual returns (uint8) {
        return IOracleReader(address(this)).decimals(token);
    }

    ///

    function _price(address token) internal view virtual returns (uint) {
        return IOracleReader(address(this)).price(token);
    }

    function _timestamp(address token) internal view virtual returns (uint) {
        return IOracleReader(address(this)).timestamp(token);
    }

    ///

    function _isWithinTheLastHour(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastHour(token);
    }

    function _isWithinTheLastDay(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastDay(token);
    }

    function _isWithinTheLastWeek(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastWeek(token);
    }

    function _isWithinTheLastMonth(address token) internal view virtual returns (bool) {
        return IOracleReader(address(this)).isWithinTheLastMonth(token);
    }
}