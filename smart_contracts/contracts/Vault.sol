/* $ETH -> In | -> $DREAM out */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "smart_contracts/libraries/Math.sol";
import "smart_contracts/contracts/Conduit.sol";

contract Vault is Conduit {
    /*
    pre seed funding - $0.035
    seed funding - $0.05
    series A - $0.25
    series B - $0.50
    initial coin offering
     */

    mapping(string => address) tokenContracts;

    function initVault() {
        // deploy with pre existing contracts likely what we'll be selling the token for at first
        tokenContracts["USDT"] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokenContracts["WBTC"] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        tokenContracts["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }

    function newSupported(string memory _symbol, address _tokenContract) {
        /*
        ability to add new token addresses to our knowledgebase of the ones the contract is aware of
        if we already have the symbol then we'll just update the contract address
         */

        require(
            tokenContracts[_symbol] != _tokenContract,
            "We already know we have this"
        );
        tokenContracts[_symbol] = _tokenContract;
    }
}
