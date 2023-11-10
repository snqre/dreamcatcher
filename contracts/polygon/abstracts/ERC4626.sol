// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/** 
* @title ERC-4626 Tokenized Vault. 
*
* https://eips.ethereum.org/EIPS/eip-4626.
*
* ABSTRACT The following standard allows for the implementation of a
*          standardized API for tokenized Vaults representing shares of a
*          single underlying EIP-20 token. This standard is an extension
*          on the EIP-20 token that provides basic functionality for
*          depositing and withdrawing tokens and reading balances.
 */
abstract contract ERC4626 {

    /**
    * @dev { sender } has exchanged { assets } for { shares }, and transferred
    *      those { shares } to { owner }.
    *
    * MUST be emitted when tokens are deposited into the Vault via the { mint }
    *      and { deposit } methods.
     */
    event Deposit(address indexed sender, address indexed owner, uint assets, uint shares);

    /**
    * @dev { sender } has exchanged { shares }, owned by { owner }, for
    *      { assets }, and transferred those { assets } to { receiver }.
    *
    * MUST be emitted when shares are withdrawn from the Vault in
    *      { EIP-4626.redeem } or { EIP-4626.withdraw } methods.
     */
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint assets, uint shares);

    /** 
    * @dev The address of the underlying token used for the Vault for 
    *      accounting, depositing, and withdrawing. 
    *
    * MUST be an EIP-20 token contract.
    *
    * MUST NOT revert.
    */
    function asset() public view virtual returns (address);

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
    function convertToShares(uint assets) public view virtual returns (uint);

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
    function convertToAssets(uint shares) public view virtual returns (uint);


    /**
    * @dev Maximum amount of the underlying asset that can be deposited into
    *      the Vault for the { receiver }, through a { deposit } call.
    *
    * MUST return the maximum amount of assets { deposit } would allow to be
    *      deposited for { receiver } and not cause a revert, which MUST NOT
    *      be higher that the actual maximum that would be accepted (it should
    *      underestimate if necessary). This assumes that the uder has infinite
    *      assets, i.e MUST NOT reply on { balanceOf } of { asset }.
    *
    * MUST factory in both global and user-specific limits, like if deposits
    *      are entirely disabled (even temporarily) it MUST return 0.
    *
    * MUST return { 2 ** 256 - 1 } if there is no limit on the maximum amount
    *      of assets that may be deposited.
    *
    * MUST NOT revert.
     */
    function maxDeposit(address receiver) public view virtual returns (uint);

    /**
    * @dev Allows an on-chain or off-chain user to simulate the effects of
    *      their deposit at the current block, given current on-chain
    *      conditions.
    *
    * MUST return as close to and no more than the exact amount of Vault
    *      shares that would b minted in a { deposit } call in the same
    *      transaction ie. { deposit } should return the same or more
    *      { sahres } as { previewDeposit } if called in the same
    *      transaction.
    *
    * MUST NOT account for deposit limits like those returned from
    *          maxDeposit and should always act as though the deposit would
    *          be accepted, regardless if the user has enough tokens
    *          approved, etc.
    *
    * MUST be inclusive of deposit fees. Integrators should be aware of
    *      the existence of deposit fees.
    *
    * MUST NOT revert due to vault specific user/global limits. MAY revert
    *          due to other conditions that would also cause deposit to
    *          revert.
    *
    * NOTE That any unfavorable discrepancy between { convertToShares }
    *      and { previewDeposit } SHOULD be considered slippage in share
    *      price or some other type of condition, meaning the depositor
    *      will lose assets by depositing.
     */
    function previewDeposit(uint assets) public view virtual returns (uint);

    /**
    * @dev Mints { shares } Vault shares to { receiver } by depositing exactly
    *      { assets } of underlying tokens.
    *
    * MUST emit the { Deposit } event.
    *
    * MUST support EIP-20 { approve }/{ transferFrom } on { asset } as a
    *      deposit flow. MAY support an additional flow in which the
    *      underlying tokens are ownedby the Vault contract before the
    *      { deposit } execution, and are accounted for during 
    *      { deposit }.
    *
    * MUST revert if all of { assets } cannot be deposited (due to deposit
    *      limit being reached, slippage, the user not approving enough
    *      underlying tokens to the Vault contract, etc).
    *
    * NOTE That most implementations will require pre-approval of the Vault
    *      with the Vault's underlying { asset } token.
     */
    function deposit(uint asssets, address receiver) public virtual returns (uint);

    /**
    * @dev Maximum amount of shares that can be minted from the Vault for the
    *      { receiver } through a { mint } call.
    *
    * MUST return the maximum amount of shares { mint } would allow to be
    *      deposited to { receiver } and not cause a revert, which MUST NOT
    *      be higher than the actual maximum that would be accepted (if should
    *      underestimate if necessary). This assumes that the user has
    *      infinite assets, ie. MUST NOT rely on { balanceOf } of { asset }.
    *
    * MUST factor in both global and user-specific limits, like if mints are
    *      entirely disabled (even temporarily) it MUST return 0.
    *
    * MUST return { 2 ** 256 - 1 } if there is no limit on the maximum
    *      amount of shares that may be minted.
    *
    * MUST NOT revert.
     */
    function maxMint(address receiver) public view virtual returns (uint);

    /**
    * @dev Allows an on-chain or off-chain user to simulate the effects of
    *      their mint at the current block, given current on-chain 
    *      conditions.
    *
    * MUST return as close to and no fewer than the exact amount of assets
    *      that would be depositted in a { mint } call in the same
    *      transaction. ie. { mint } should return the same or fewer
    *      { assets } as { previewMint } if called in the same 
    *      transaction.
    *
    * MUST NOT account for mint limits like those returned from maxMint
    *          and should always act as though the mint would be accepted,
    *          regardless if the user has enough tokens, approved, etc.
    *
    * MUST be inclusive of deposit fees. Integrators should be aware of the
    *      existence of deposit fees.
    *
    * MUST NOT revert due to vault specific user/global limits. MAY revert
    *          due to other conditions that would also cause { mint } to
    *          revert.
    *
    * NOTE That any unfavorable discrepancy between { convertToAssets } and
    *      { previewMint } SHOULD be considered slippage in share price or
    *      some other type of condition, meaning the depositor will
    *      lose assets by minting.
     */
    function previewMint(uint shares) public view virtual returns (uint);

    /**
    * @dev Mints exactly { shares } Vault shares to { receiver } by
    *      depositing { assets } of underlying tokens.
    *
    * MUST emit the { Deposit } event.
    *
    * MUST support EIP-20 { approve }/{ transferFrom } on { asset } as
    *      a mint flow. MAY support an additional flow in which the
    *      underlying tokens are owned by the Vault contract before
    *      the { mint } execution, and are accounted for duration 
    *      { mint }.
    *
    * MUST revert if all of { shares } cannot be minted (due to deposit
    *      limit being reached, slippage, the user not approving enough 
    *      underlying tokens to the Vault contract, etc).
    *
    * NOTE That most implementations will require pre-approval of the
    *      Vault with the Vault's underlying { asset } token.
     */
    function mint(uint shares, address receiver) public virtual returns (uint);

    /**
    * @dev Maximum amount of the underlying asset that can be withdrawn
    *      from the { owner } balance in the Vault, through a { withdraw }
    *      call.
    *
    * MUST return the maximum amount of assets that could be transferred
    *      from { owner } through { withdraw } and not cause a revert,
    *      which MUST NOT be higher than the actual maximum that
    *      would be accepted (it should underestimate if necessary).
    *
    * MUST factory in both global and user-specific limits, like
    *      withdrawals are entirely disabled (even temporarily) it MUST
    *      return 0.
    *
    * MUST NOT revert.
     */
    function maxWithdraw(address owner) public view virtual returns (uint);

    /**
    * @dev Allows an on-chain or off-chain user to simulate the effects of
    *      their withdrawal at the current block, given current on-chain
    *      conditions.
    *
    * MUST return as close to and no fewer than the exact amount of Vault
    *      shares that would be burned in a { withdraw } call in the same
    *      transaction. ie. { withdraw } should return the same or fewer
    *      { shares } as { previewWithdraw } if called in the same
    *      transaction.
    *
    * MUST NOT account for withdrawal limits like those returned from
    *          maxWithdraw and should always act as though the withdrawal
    *          would be accepted, regardless if the user has enough enough
    *          shares, etc.
    *
    * MUST be inclusive of withdrawal fees. Integrators should be aware of the
    *      existence of withdrawal fees.
    *
    * MUST NOT revert due to vault specific user/global limits. MAY revert due
    *          to other conditions that would also cause { withdraw } to
    *          revert.
    *
    * NOTE That any unfavorable discrepancy between { convertToShares } and
    *      { previewWithdraw } SHOULD be considered slippage in share price
    *      or some other type of condition, meaning the depositor will lose
    *      assets by depositing.
     */
    function previewWithdraw(uint assets) public view virtual returns (uint);

    /**
    * @dev Burns { shares } from { owner } and sends exactly { assets } of
    *      underlying tokens to { receiver }.
    *
    * MUST emit the { Withdraw } event.
    *
    * MUST support a withdraw flow where the shares are burned from { owner }
    *      directly where { owner } is { msg.sender }.
    *
    * MUST support a withdraw flow where the shares are burned from { owner }
    *      directly where { msg.sender } has EIP-20 approval over the shares
    *      of { owner }.
    *
    * MAY support an additional flow in which the sahres are transferred to
    *     the Vault contract before the { withdraw } execution, and are
    *     accounted for during { withdraw }.
    *
    * SHOULD check { msg.sender } can spend owner funds, assets needs to be
    *        converted to shares and shares should be checked for allowance.
    *
    * MUST revert if all of { assets } cannot be withdrawn (due to withdrawal
    *      limit being reached, slippage, the owner not having enough shares,
    *      etc).
    *
    * NOTE That some implementations will require pre-requesting to the Vault
    *      before a withdrawal may be performed. Those methods should be
    *      performed separately.
     */
    function withdraw(uint assets, address receiver, address owner) public virtual returns (uint);

    /**
    * @dev Maximum amount of Vault shares that can be redeemed from the
    *      { owner } balance in the Vault, through a { redeem } call.
    *
    * MUST return the maximum amount of shares that could be transferred
    *      from { owner } through { redeem } and no cause a revert, which
    *      MUST NOT be higher than the actual maximum that would be
    *      accepted (it should understimate if necessary).
    *
    * MUST factory in both global and user-specific limits, like if redemption
    *      is entirely disabled (even temporarily) it MUST return 0.
    *
    * MUST NOT revert.
     */
    function maxRedeem(address owner) public view virtual returns (uint);

    /**
    * @dev Allows an on-chain or off-chain user to simulate the effects of
    *      their redeemption at the current block, given curren on-chain
    *      conditions.
    *
    * MUST return as close to and no more than the exact amount of assets
    *      that would be withdrawn in a { redeem } call in the same
    *      transaction. ie. { redeem } should return the same or more
    *      { assets } as { previewRedeem } if called in the same
    *      transaction.
    *
    * MUST NOT account for redemption limits like those returns from maxRedeem
    *          and should always act as though the redemption would be
    *          accepted, regardless if the user has enough shares, etc.
    *
    * MUST be inclusive of withdrawal fees. Integrators should be aware of
    *      the existence of withdrawal fees.
    *
    * MUST NOT revert due to vault specific user/global limits. MAY revert
    *          due to other conditions that would also cause { redeem } to
    *          revert.
    *
    * NOTE That any unfavorable discrepancy between { convertToAssets } and
    *      { previewRedeem } SHOULD be considered slippage in share price or
    *      some other type of condition, meaning the depositor will lose
    *      assets by redeeming.
     */
    function previewRedeem(uint shares) public view virtual returns (uint);

    /**
    * @dev Burns exactly { shares } from { owner } and sends { assets } of
    *      underlying tokens to { receiver }.
    *
    * MUST emit the { Withdraw } event.
    *
    * MUST support a redeem flow where the shares are burned from { owner }
    *      directly where { owner } is { msg.sender }.
    *
    * MUST support a redeem flow where the shares are burned from { owner }
    *      directly where { msg.sender } has EIP-20 approval over the
    *      shares of { owner }.
    *
    * MAY support an additional flow in which the shares are transferred to
    *     the Vault contract before the { redeem } execution, and are
    *     accounted for during { redeem }.
    *
    * SHOULD check { msg.sender } can spend owner funds using allowance.
    *
    * MUST revert if all of { shares } cannot be redeemed (due to withdrawal
    *      limit being reached, slippage, the owner not having enough 
    *       shares, etc).
    *
    * NOTE That some implementations will require pre-requresting to the
    *      Vault before a withdrawal may be performed. Those methods should
    *      be performed separately.
     */
    function redeem(uint shares, address receiver, address owner) public virtual returns (uint);
}