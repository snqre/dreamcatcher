// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract ERC4626Lite is StorageLite {

    /** 
    * @dev The address of the underlying token used for the Vault for 
    *      accounting, depositing, and withdrawing. 
    *
    * MUST be an EIP-20 token contract.
    *
    * MUST NOT revert.
    */
    function asset() public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____asset()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        return abi.decode(_bytes[____asset()], (address));
    }

    /** 
    * @dev Total amount of the underlying asset that is “managed” by Vault.
    *
    * MUST be an EIP-20 token contract.
    *
    * MUST NOT revert.
    */
    function totalAssets() public view virtual returns (uint);

    /** 
    * @dev The amount of shares that the Vault would exchange for the amount of 
    *      assets provided, in an ideal scenario where all the conditions are
    *      met.
    *
    * MUST NOT be inclusive of any fees that arre charged against assets 
    *          in the Vault.
    *
    * MUST NOT show any variations depending on the caller.
    *
    * MUST NOT reflect slippage or other on-chain conditions, when performing
    *          the actual exchange.
    *
    * MUST NOT revert unless due to integer overflow caused by an unreasonably
    *          large input.
    *
    * MUST round down towards 0.
    *
    * @dev This calculation MAY NOT reflect the "per-user" price-per-share,
    *      and instead should reflect the "average-user's" price-per-share,
    *      meaning what the average user should expect to see when
    *      exchanging to and from.
    */
    function convertToShares() public view virtual returns (uint);

    /**
    * @dev The amount of assets that the Vault would exchange for the amount 
    *      of shares provided, in an ideal scenario where all the conditions 
    *      are met.
    *
    * MUST NOT be inclusive of any fees that are charged against assets
    *          in the Vault.
    *
    * MUST NOT show any variations depending on the caller.
    *
    * MUST NOT reflect slippage or other on-chain conditions, when
    *          performing the actual exchange.
    *
    * MUST NOT revert unless due to interger overflow caused by an unreasonably
    *          large input.
    *
    * MUST round down towards 0.
    *
    * @dev This calculation MAY NOT reflect the "per-user" price-per-share, and
    *      instead should reflect the "average-user's" price-per-share,
    *      meaning what the average user should expect to see when exchanging
    *      to and from.
     */
    function convertToAssets() public view virtual returns (uint);

    /**
    * Maximum amount of the underlying asset that can be deposited 
    * into the Vault for the receiver, through a deposit call.
     */
    function maxDeposit() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____maxDeposit()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____maxDeposit()], (uint));
    }

    function ____asset() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("ASSET"));
    }

    function ____maxDeposit() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("MAX_DEPOSIT"));
    }
}