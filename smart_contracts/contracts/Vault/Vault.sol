/* $ETH -> In | -> $DREAM out */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract State {

    mapping (address => bool) internal admin;
}

interface IAuthenticator {
    
    function grantPermissionAdmin(address _owner) external returns (bool);
    function revokePermissionAdmin(address _owner) external returns (bool);
}

contract Authenticator is IAuthenticator, State {

        modifier onlyAdmin() {
        address _sender = msg.sender;
        require(
            admin[_sender] != false,
            "onlyAdmin"
        );
        _;
    }

    function grantPermissionAdmin(address _owner) public onlyAdmin returns (bool) {
        require(
            _owner != address(0) &&
            admin[_owner] != true
        );
        admin[_owner] = true;
        return true;
    }

    function revokePermissionAdmin(address _owner) public onlyAdmin returns (bool) {
        require(
            _owner != address(0) &&
            admin[_owner] != false
        );
        admin[_owner] = false;
        return true;
    }
}

/**
Conduit is designed to connect to other contract safely, as well as, our contracts and should handle error
 */

interface IERC20 {
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
}

interface IConduit {
    function ITransfer(address _token, address _to, uint256 _value) external returns (bool);

}

contract Conduit is IConduit, Authenticator {
    // approve all transaction then send from **only admin can call
    function ITransfer(address _token, address _to, uint256 _value) public onlyAdmin retruns (bool) {
        require(
            _token != address(0) &&
            _to != address(0) &&
            IERC20(_token).approve(msg.sender, _value);
            ERC20(_token).allowance(msg.sender, address(this)) >= _value &&
            ERC20(_token).transferFrom(msg.sender, _to, _value)
        );
        return true;
    }
}

interface Vault is Conduit {
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
