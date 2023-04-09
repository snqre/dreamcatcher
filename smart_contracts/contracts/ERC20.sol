// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "smart_contracts/contracts/BaseERC20.sol";
import "smart_contracts/contracts/Proposal.sol";
import "smart_contracts/libraries/Meta.sol";

// voting mechanism here
contract ERC20 is BaseERC20, Proposal {
    Meta.Settings internal settings;

    function checkRole(address _account) internal virtual returns (bool) {
        uint256 balance = database.balance[_account];
        uint256 staked = database.staked[_account];
        if (
            balance >= settings.minBalanceForMembership &&
            staked >= settings.minStakeForMembership &&
            isMember[_account] != true
        ) {
            giveMembership(_account);
        } else if (
            balance < settings.minBalanceForMembership &&
            staked < settings.minStakeForMembership &&
            isMember[_account] != false
        ) {
            takeMembership(_account);
        }
        if (
            balance >= settings.minBalanceForSyndicate &&
            staked >= settings.minStakeForSyndicate
        ) {
            // if you meet the requirements you have to be elected to be a syndicate
        } else if (
            balance < settings.minBalanceForSyndicate &&
            staked < settings.minStakeForSyndicate &&
            isSyndicate[_account] != false
        ) {
            // if you unstake or leave your role as a syndicate will be terminated on the transaction.
            takeSyndicate(_account);
        }
        return true;
    }

    function transfer(address _recipient, uint256 _amount)
        public
        virtual
        override
        reentrancyLock
        returns (bool)
    {
        bool result;
        result = super.transfer(_recipient, _amount);
        require(result != false);
        database.vote[msg.sender] -= _amount;
        database.vote[_recipient] += _amount;
        // check and validate roles and more
        checkRole(_recipient);
        checkRole(msg.sender);
        return result;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual override reentrancyLock returns (bool) {
        bool result;
        result = super.transferFrom(_sender, _recipient, _amount);
        require(result != false);
        database.vote[_sender] -= _amount;
        database.vote[_recipient] += _amount;
        checkRole(_sender);
        checkRole(_recipient);
        return result;
    }

    function burn(address _account, uint256 _amount)
        internal
        virtual
        override
        reentrancyLock
        returns (bool)
    {
        bool result;
        result = super.burn(_account, _amount);
        require(result != false);
        database.vote[_account] -= _amount;
        checkRole(_account);
        return result;
    }

    function mint(address _account, uint256 _amount)
        internal
        virtual
        override
        returns (bool)
    {
        bool result;
        result = super.mint(_account, _amount);
        require(result != false);
        database.vote[_account] += _amount;
        checkRole(_account);
        return result;
    }

    function release() public override returns (bool) {
        uint256 balanceBefore;
        uint256 balanceAfter;
        bool result;
        balanceBefore = database.balance[msg.sender];
        result = super.release();
        require(result != false);
        balanceAfter = database.balance[msg.sender];
        // correct the votes value
        // i know we can do it inside the inherited function but this keeps the code cleaner
        database.vote[msg.sender] += (balanceAfter - balanceBefore);
        checkRole(msg.sender);
        return result;
    }

    function getVotes(address _account) public view returns (uint256) {
        return database.vote[_account];
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint256 _maxSupply
    ) BaseERC20() {
        properties.name = _name;
        properties.symbol = _symbol;
        properties.decimals = _decimals;
        properties.maxSupply = _maxSupply * 10**_decimals;
    }

    // votes?
    function getVotes(address account) public view returns (uint256) {}

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {}

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber)
        public
        view
        returns (uint256)
    {}

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) public view returns (address) {}

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external {}

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {}
}
