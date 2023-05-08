pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Dreamcatcher/Authenticator.sol";
import "blockchain/contracts/Polygon/Dreamcatcher/Treasury.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Token/Token.sol";
import "blockchain/contracts/Polygon/Dreamcatcher/PoolFactory.sol";
import "blockchain/contracts/Polygon/Dreamcatcher/State.sol";
/**
* the terminal is the logic for the dreamcatcher system
* it connects to all other contracts
*
 */
contract Terminal {
    struct Code {
        address treasury;
        address authenticator;
        address nativeToken;
        address poolFactory;
        address state;
    } Code private code;

    Treasury private treasury;
    Authenticator private authenticator;
    Token private nativeToken;
    PoolFactory private poolFactory;
    State private state;

    constructor() {
        treasury = new Treasury();
        authenticator = new Authenticator();
        nativeToken = new Token();
        poolFactory = new PoolFactory();

        /** assign initial roles */
        authenticator._setAdmin_(0xDbF85074764156004FEb245b65693e59a62262c2);
        authenticator._setExecutive_(0xDbF85074764156004FEb245b65693e59a62262c2, true);

        /** initial distribution */
        nativeToken.mint(0xDbF85074764156004FEb245b65693e59a62262c2, 1_000_000);
    }
    // deposit matic to dreamcatcher
    function deposit() public payable returns (bool) {
        // route deposit directly to treasury contract
        treasury._deposit_();
        return true;
    }
    // transfer matic from dreamcatcher to address
    function transfer(address payable _to, uint256 _value) public returns (bool) {
        treasury._withdraw_(_to, _value);
        return true;
    }
    // deposit erc20 token to dreamcatcher
    function depositERC20(address _contract, uint256 _value) public returns (bool) {
        address _from = msg.sender;
        treasury._depositERC20_(_contract, _from, _value);
        return true;
    }
    // transfer erc20 token from dreamcatcher to address
    function transferERC20(
        address _contract,
        address payable _to,
        address _value
    ) public returns (bool) {
        treasury._withdrawERC20_(_contract, _to, _value);
        return true;
    }

    

    

}