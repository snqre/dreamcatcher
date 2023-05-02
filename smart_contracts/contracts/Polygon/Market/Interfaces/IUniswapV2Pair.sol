pragma solidity ^0.5.0;
import "smart_contracts/contracts/Polygon/ERC20Standards/IERC20.sol";

interface IUniswapV2Pair is IERC20 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address _owner) external view returns (uint256);

    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    event Mint(address indexed _sender, uint256 _amount0, uint256 _amount1);
    event Burn(
        address indexed _sender,
        uint256 _amount0,
        uint256 _amount1,
        address indexed _to
    );
    event Swap(
        address indexed _sender,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amount0Out,
        uint256 _amount1Out,
        address indexed _to
    );

    event Sync(uint112 _reserve0, uint112 _reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address _to) external returns (uint256 _liquidity);

    function burn(address _to)
        external
        returns (uint256 _amount0, uint256 _amount1);

    function swap(
        uint256 _amount0Out,
        uint256 _amount1Out,
        address _to,
        bytes calldata _data
    ) external;

    function skim(address _to) external;

    function sync() external;

    function initialize(address, address) external;
}
