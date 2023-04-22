/* $ETH -> In | -> $DREAM out */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/libraries/Math.sol";
import "smart_contracts/contracts/Conduit.sol";
interface Vault {
    // must call receive function or the value given will not be taken into consideation, hence being lost forever
    function receive();
    function sent(); // send token or balance to a place 
}

contract Vault is Conduit {
    /*
    pre seed funding - $0.035
    seed funding - $0.05
    series A - $0.25
    series B - $0.50
    initial coin offering
     */
    
    event NewSupportedTokenContractAdded(string symbol, address indexed token);
    event SupportedTokenContractDeleted(string symbol);
    function vaultInit() internal {
        // deploy with pre existing contracts likely what we'll be selling the token for at first
        tokens["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokens["WBTC"] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        tokens["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokens["LINK"] = 
        tokens["BNB"] = 
        tokens["LOCG"] = 

    }

    function newSupportedTokenContract(string memory symbol, address token) public checkVaultIsPaused onlyAdmin {
        require(tokens[symbol] != token, "token already supported");
        tokens[symbol] = token;
        emit NewSupportedTokenContractAdded(symbol, token);
    }

    function delSupportedTokenContract(string memory symbol) public checkVaultIsPaused onlyAdmin {
        delete tokens[symbol];
        emit SupportedTokenContractDeleted(symbol);
    }

}
