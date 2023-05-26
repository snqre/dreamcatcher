// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "blockchain/contracts/Polygon/ERC20Standards/Tokens/DreamToken.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/EmberToken.sol";

contract Terminal is ReentrancyGuard {
    DreamToken dreamToken;
    EmberToken emberToken;

    mapping(address => bool) private objWhitelist;

    constructor() {
        dreamToken = new DreamToken();
        emberToken = new EmberToken();
    }

    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**18;
    }

    function _setObjWhitelist(address obj, bool isWhitelisted) internal {
        objWhitelist[obj] = isWhitelisted;
    }

    function _safeConnect(address obj, string memory signature, bytes memory args) internal returns (bool) {
        require(
            objWhitelist[obj],
            "Terminal::_safeConnect: contract is not whitelisted"
        );
        
        (
            bool success,
        ) = address(obj).delegatecall(abi.encodeWithSignature(signature, arg));

        require(
            success,
            "Terminal::_safeConnect: delegatecall failed"
        );

        return true;
    }

    
    
}