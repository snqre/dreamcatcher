// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "deps/openzeppelin/token/ERC20/ERC20.sol";
import "deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "deps/openzeppelin/access/AccessControl.sol";

import "smart_contracts/utils/Utils.sol";
import "smart_contracts/tokens/ember_token/EmberToken.sol";
import "smart_contracts/finance/wallets/linear_vested_wallet/LinearVestedWallet.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    uint mintable_;
    
    EmberToken emberToken;

    constructor(address[] memory admins) ERC20("DreamToken", "DRMK") ERC20Permit("DreamToken") {
        mintable_ = Utils.convertToWei(200000000);

        for (uint i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }

        _mint(terminal, Utils.convertToWei(180000000));

        /**
         * @dev Here we deploy Ember token
         */
        emberToken = new EmberToken(terminal);
    }

    function _mustBeAdmin() internal view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "must be an admin");
    }

    function _mustNotBeFutureLookup(uint snapshotId) internal view {
        require(snapshotId <= _getCurrentSnapshotId(), "must not be future lookup");
    }

    function _mustBeMintable(uint amount) {
        require(amount <= mintable, "insufficient mintable amount left");
    }

    /**
     * @dev This is a required override
     */
    function _beforeTokenTransfer(address from, address to, uint amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint amount) internal override {
        super._afterTokenTransfer(from, to, amount);
    }

    // overriden function to check mintable_
    function _mint(address to, uint amount) internal override {
        _mustBeMintable(amount);
        mintable_ -= amount;
        super._mint(to, amount);
    }

    /**
     * @dev Creates a snapshot and returns the snapshot reference
     * @notice Will also snapshot Ember Token
     */
    function snapshot() public onlyAdmin returns (uint) {
        _snapshot();

        // also snapshot for $ember
        emberToken.snapshot();

        return _getCurrentSnapshotId();
    }

    function mint(address to, uint amount) public onlyAdmin {
        _mint(to, amount);
    }

    function emberMint(address to, uint amount) public onlyAdmin {
        emberToken.mint(to, amount);
    }

    // see $ember mintByPoints()
    function emberMintByPoints(address to, uint points) public onlyAdmin {
        emberToken.mintByPoints(to, points);
    }

    function emberBurn(uint amount) public onlyAdmin {
        emberToken.burn(amount);
    }

    function emberBurnFrom(address from, uint amount) public onlyAdmin {
        emberToken.burnFrom(from, amount);
    }
    
    // see $ember split()
    function emberSplit(uint mul) public onlyAdmin {
        emberToken.split(mul);
    }

    // see $ember stack()
    function emberStack(uint div) public onlyAdmin {
        emberToken.stack(div);
    }

    function mintable() public view returns (uint) {
        return mintable_;
    }

    // The getVotes() function calculates and returns the total number of votes for an account in the current snapshot. It retrieves the base votes by getting the account's balance at the current snapshot using balanceOfAt(). It then fetches the weight of the account using emberToken.getWeight(account). After that, it calculates the additional votes by multiplying the base votes with the weight and dividing by 10000. Finally, it returns the sum of the base votes and additional votes.
    function getVotes(address account) public view returns (uint) {
        uint baseVotes = balanceOfAt(account, _getCurrentSnapshotId());
        uint weight = emberToken.getWeight(account);
        uint additionalVotes = (baseVotes * weight) / 10000;

        return baseVotes + additionalVotes;
    }

    // The getPastVotes() function calculates and returns the total number of votes for an account at a specific snapshotId in the past. It retrieves the base votes by getting the account's balance at the given snapshotId using balanceOfAt(). It then fetches the weight of the account at the same snapshotId using emberToken.getPastWeight(account, snapshotId). After that, it calculates the additional votes by multiplying the base votes with the weight and dividing by 10000. Finally, it returns the sum of the base votes and additional votes.
    function getPastVotes(address account, uint snapshotId) public view checkFutureLookup(snapshotId) returns (uint) {
        uint baseVotes = balanceOfAt(account, snapshotId);
        uint weight = emberToken.getPastWeight(account, snapshotId);
        uint additionalVotes = (baseVotes * weight) / 10000;

        return baseVotes + additionalVotes;
    }

    // The getCurrentTotalSupply() function returns the total supply of a token at the current snapshot ID.
    function getCurrentTotalSupply() public view returns (uint) {
        return totalSupplyAt(_getCurrentSnapshotId());
    }

    // The getWeight() function calculates and returns the weight of an account based on its balance relative to the current total supply of the token.
    function getWeight(address account) public view returns (uint) {
        uint balance = balanceOfAt(account, _getCurrentSnapshotId());

        return (balance / getCurrentTotalSupply()) * 10000;
    }

    // The getPastWeight() function calculates and returns the weight of an account at a specific snapshotId in the past. It ensures that the provided snapshotId is not in the future, and then calculates the weight based on the account's balance at that snapshot relative to the total supply at that snapshot.
    function getPastWeight(address account, uint snapshotId) public view checkFutureLookup(snapshotId) returns (uint) {
        balance = balanceOfAt(account, snapshotId);

        return (balance / totalSupplyAt(snapshotId)) * 10000;
    }

    // The emberGetWeight() function simply calls the getWeight() function of another contract emberToken and returns the result. It retrieves the weight of an account using the emberToken contract.
    function emberGetWeight(address account) public view returns (uint) {
        return emberToken.getWeight(account);
    }

    // The emberGetPastWeight() function calls the getPastWeight() function of another contract emberToken with the specified account and snapshotId parameters. It retrieves the weight of an account at a specific snapshotId using the emberToken contract.
    function emberGetPastWeight(address account, uint snapshotId) public view checkFutureLookup(snapshotId) returns (uint) {
        return emberToken.getPastWeight(account, snapshotId);
    }
}