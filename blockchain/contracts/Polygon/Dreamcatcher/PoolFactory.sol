// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/Pool/Prototype/ClosedPool/Pool.sol";
import "blockchain/contracts/Polygon/ERC20Standards/IERC20.sol";
import "blockchain/contracts/Polygon/Dreamcatcher/State.sol";

contract PoolFactory {
    struct Code {
        address main;
        address nativeToken;
        address treasury;
        address state;
    } Code private code;
    mapping(string => Pool) private poolAs;
    
    modifier main() {
        require(msg.sender == code.main, "PoolFactory: msg.sender is not main contract");
        _;
    }
    /** this is where people can access our pools from */
    function foundNewPool(
        string memory _name,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenInitialSupply
    ) public payable returns (bool) {
        /** transfer our native token from their wallet to our vault */
        IState _state = IState(code.state);
        uint256 _feeFoundNewPool = state.feeFoundNewPool;
        address _from = msg.sender;
        address _to = code.treasury;
        uint256 _value = _feeFoundNewPool * 10**18;
        require(
            _from != address(0) &&
            _to != address(0) &&
            _value >= 0
        );
        IERC20 _nativeToken = IERC20(code.nativeToken);
        _nativeToken.transferFrom(_from, _to, _value);
        /** create the pool */
        poolAs[_tokenSymbol] = new Pool(
            _name,
            _tokenName,
            _tokenSymbol,
            _tokenInitialSupply
        );
    }
}