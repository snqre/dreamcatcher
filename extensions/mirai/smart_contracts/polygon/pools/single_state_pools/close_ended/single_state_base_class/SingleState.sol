// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

// once these are loaded into the project must import locally
/**
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
*/

// if this format is ok then we are fine
import "blockchain/contracts/Polygon/Pools/Prototype/Utils.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/SimpleToken.sol" as SimpleTokenContract;
import "blockchain/contracts/Polygon/Finance/Medium.sol";

// we use this for centralized pools because they dont need their dedicated voting mechanism



interface ISingleState {
    event NewPoolCreated(
        string name,
        string description,
        address tokenContract,
        uint256 initialSupply,
        uint64 startTime,
        uint64 duration,
        uint target,
        uint required,
        bool hasWhitelist,
        bool isVerified,
        bool onlyVerifiedAssets,
        address[] admins,
        address[] managers
    );
}

/**
no: is the unique number generated for each pool in the contract
this is used to select which pool is being refered to in functions
 */
contract SingleState is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuard, AccessControl {
    struct Fee {
        uint256 createNewPool;
        uint256 contribute;
        uint256 withdraw;
        uint256 update;
    }

    struct FundingSchedule {
        uint64 startTime;
        uint64 duration;
        uint256 target;
        uint256 required;
        bool hasWhitelist;
        bool isVerified;
        bool success;
    }

    struct CollatTSchedule {
        uint256 startTime;
        uint256 duration;
        uint256 collateral;
        bool complete;
    }

    struct Reserve {
        address[] contracts;
        address[] amounts;
        uint256 balance;
        bool onlyVerifiedAssets;
    }

    struct Pool {
        uint256 no;
        bytes32 class;
        string name;
        string description;
        StandardToken standardToken;
        GovernanceToken governanceToken;
        FundingSchedule fundingSchedule;
        Reserve reserve;
        CollatTSchedule collatTSchedules;
    }

    struct Account { // i know this is more gas heavy but this makes code more readable and flexible
        bool[] isAdminOf;
        bool[] isCreatorOf;
        bool[] isManagerOf;
        bool[] isOnWhitelistOf;
        bool[] isParticipantOf;
        bool hasCompletedKYC;
        bool isVerified;
        uint256 reputationScore;
    }

    uint256 poolCount;

    Fee public fee;

    mapping(uint256 => Pool) public pools;
    mapping(address => Account) public accounts;

    bytes32 decentralized = keccak256(abi.encodePacked("decentralized"));
    bytes32 centralized = keccak256(abi.encodePacked("centralized"));
    bytes32 hybrid = keccak256(abi.encodePacked("hybrid"));

    address public terminal; // all roads lead to terminal

    // this is the amount of time after the start of a funding schedule
    // that contributors can withdraw
    // assuming the funding schedule has not succeeded yet
    uint64 public lockUpPeriod;

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyAdminOf(uint no) {
        Account memory caller = accounts[msg.sender];
        require(
            caller.isAdminOf[no],
            "SingleState::onlyAdminOf(): caller is not admin of selected pool"
        );
        _;
    }

    modifier onlyCreatorOf(uint no) {
        Account memory caller = accounts[msg.sender];
        require(
            caller.isAdminOf[no],
            "SingleState::onlyAdminOf(): caller is not admin of selected pool"
        );
        _;
    }

    modifier onlyManagerOf(uint no) {
        Account memory caller = accounts[msg.sender];
        require(
            caller.isAdminOf[no],
            "SingleState::onlyAdminOf(): caller is not admin of selected pool"
        );
        _;
    }

    modifier onlyOnWhitelistOf(uint no) {
        Pool memory pool = pools[no];
        if (pool.fundingSchedule.hasWhitelist) {
            Account memory caller = accounts[msg.sender];
            require(
                caller.isAdminOf[no],
                "SingleState::onlyAdminOf(): caller is not admin of selected pool"
            );
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address terminal_) initializer public {
        __Pausable_init();
        __Ownable_init();
        
        if (msg.sender != terminal_) {
            _grantRole(DEFAULT_ADMIN_ROLE, address(this));
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
            _grantRole(DEFAULT_ADMIN_ROLE, terminal_);
        } else {
            _grantRole(DEFAULT_ADMIN_ROLE, address(this));
            _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }

        terminal = terminal_;

        lockUpPeriod = 4 weeks;
    }

    /*//////////////////////////////////////////////////////////////
                               PRIVATE
    //////////////////////////////////////////////////////////////*/
    /*---------------------------------------------------------------- GETPOOL **/
    function _getPool(uint no) internal returns (Pool) {
        return pools[no];
    }

    /*---------------------------------------------------------------- GETPOOL **/
    function _getAccount(address account) internal returns (Account) {
        return accounts[account];
    }

    /*---------------------------------------------------------------- OVERWRITEPOOL **/
    function _overwritePool(uint no, Pool newPool) internal {
        pools[no] = newPool;
    }

    /*---------------------------------------------------------------- OVERWRITEACCOUNT **/
    function _overwriteAccount(address account, Account newAccount) internal {
        accounts[no] = newAccount;
    }

    /*---------------------------------------------------------------- GETNETASSETVALUEOF **/
    // this is how we get the price of assets being held by pools
    // but some assets may not be available
    // pools can decide to trade only verified assets
    // needs work
    function _getNetAssetValueOf(bytes memory args) internal returns (uint256) {
        (address oracle, uint256 id) = abi.decode(args, (address, uint256));
        Pool memory pool = pools[id];
        uint256 sum;
        /** for each asset in the pool */
        for (uint256 i = 0; i < pool.contracts.length; i++) {
            address contract_ = pool.contracts[i];
            address[] memory contract__;
            contract__[0] = contract_;
            uint256 amount = pool.amounts[i];
            args = abi.encode(contract_);
            bool isVerified = IOracle(oracle).isVerifiedInUSD(args);
            if (isVerified) {
                uint256[] memory price = IOracle(oracle).getContractsToValuesUSD(
                    abi.encode(
                        contract__
                    )
                );

                sum += amount * price[0];
            } else {
                /** do something if not verified */
            }
        }
        /** will return zero if nothing was found */
        return sum;
    }
    
    /*---------------------------------------------------------------- PUSHNEWPOOLTOSTORAGE **/
    function _pushNewPoolToStorage(
        string memory style,
        uint256 no,
        string memory name,
        string memory description,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        uint64 startTime,
        uint64 duration,
        uint256 target,
        uint256 required,
        bool hasWhitelist,
        bool isVerified,
        bool onlyVerifiedAssets,
        address[] memory admins,
        address[] memory managers,
        bool override_
    ) internal payable nonReentrant {

        if (override_ == false) {
            require(
                no >= 0,
                "SingleState::_pushNewPoolToStorage(): no < 0"
            );

            require(
                no <= type(uint256).max,
                "SingleState::_pushNewPoolToStorage(): no > type(uint256).max"
            );

            require(
                initialSupply >= Utils.convertToWei(1),
                "SingleState::_pushNewPoolToStorage(): initialSupply < 1 wei"
            );

            require(
                admins.length >= 0,
                "SingleState::_pushNewPoolToStorage(): admins.length < 0"
            );

            require(
                admins.length <= 9,
                "SingleState::_pushNewPoolToStorage(): admins.length > 9"
            );

            require(
                managers.length >= 0,
                "SingleState::_pushNewPoolToStorage(): managers.length < 0"
            );

            require(
                managers.length <= 9,
                "SingleState::_pushNewPoolToStorage(): managers.length > 9"
            );
        } 

        bytes32 style_ = Utils.convertStringToBytes32(style);

        if (style_ == decentralized || style_ == hybrid) {
            Pool pool = Pool({
                no: no,
                class: style_,
                name: name,
                description: description,
                standardToken: address(0),
                governanceToken: new GovernanceToken(
                    tokenName,
                    tokenSymbol
                ),
                fundingSchedule: FundingSchedule({
                    startTime: startTime,
                    duration: duration,
                    target: target,
                    required: required,
                    hasWhitelist: hasWhitelist,
                    isVerified: isVerified,
                    success: false
                }),
                reserve: Reserve({
                    contracts: new address[](0),
                    amounts: new address[](0),
                    balance: msg.value,
                    onlyVerifiedAssets: onlyVerifiedAssets
                }),
                collatTSchedules: new CollatTSchedule[](0)
            });

            Account memory account;
            account = accounts[msg.sender];
            account.isCreatorOf[no] = true;

            for (uint256 i = 0; i < admins.length; i++) {
                account = accounts[admins[i]];
                account.isAdminOf[no] = true;
            }

            for (uint256 i = 0; i < managers.length; i++) {
                account = accounts[managers[i]];
                account.isManagerOf[no] = true;
            }

            pools[no] = pool;
        }

        else if (style_ == centralized) {
            Pool pool = Pool({
                no: no,
                class: style_,
                name: name,
                description: description,
                standardToken: new StandardToken(
                    tokenName,
                    tokenSymbol
                ),
                governanceToken: address(0),
                fundingSchedule: FundingSchedule({
                    startTime: startTime,
                    duration: duration,
                    target: target,
                    required: required,
                    hasWhitelist: hasWhitelist,
                    isVerified: isVerified,
                    success: false
                }),
                reserve: Reserve({
                    contracts: [],
                    amounts: [],
                    balance: msg.value
                }),
                collatTSchedules: []
            });

            Account account;
            account = accounts[msg.sender];
            account.isCreatorOf[no] = true;

            if (admins.length != 0) {
                for (uint256 i = 0; i < admins.length; i++) {
                    account = accounts[admins[i]];
                    account.isAdminOf[no] = true;
                }
            }

            if (managers.length != 0) {
                for (uint256 i = 0; i < managers.length; i++) {
                    account = accounts[managers[i]];
                    account.isManagerOf[no] = true;
                }
            }

            pools[no] = pool;
        }

        else {
            revert("SingleState::_pushNewPoolToStorage(): invalid style");
        }
    }

    /*---------------------------------------------------------------- CONTRIBUTE **/
    // onlyOnWhitelistOf will not revert if there is no whitelist for the selected pool
    function _contribute(uint no, bool override_) internal payable onlyOnWhitelistOf(no) nonReentrant {
        // in this context value is the amount in matic being sent to the pool
        uint value = msg.value;

        if (override_ == false) {
            require(
                value >= 1,
                "SingleState::_contribute(): value < 1 wei"
            );
        }
        
        Account memory caller = _getAccount(msg.sender);
        Pool memory pool = _getPool(no);
        

        if (override_ == false) { // can bypass this using override
            // check eligibility
            bool fundingPeriodHasEnded = block.timestamp <= pool.fundingSchedule.startTime.add(pool.fundingSchedule.duration);
            bool fundingPeriodHasBegun = block.timestamp <= pool.fundingSchedule.startTime;

            // you cannot contribute if the funding period for the selected pool has not begun yet
            // you cannot contribute if the funding period for the selected pool has ended
            // this is the set up for close ended pools
            // there will be a contract for open ended pools as they are more difficult
            require(fundingPeriodHasBegun, "SingleState::_contribute(): the funding period has not begun yet");
            require(!fundingPeriodHasEnded, "SingleState::_contribute(): the funding period has ended");
        }

        /** replaced by onlyOnWhitelistOf modifier
        if (pool.fundingSchedule.hasWhitelist) {
            require(
                caller.isOnWhitelistOf[no],
                "SingleState::_contribute: caller is not on whitelist of the selected pool"
            );
        }
        */
        
        {
            bytes32 class = pool.class;
            if (class == decentralized || class == hybrid) {
                uint supply = pool.governanceToken.totalSupply();
            }

            else if (class == centralized) {
                uint supply = pool.standardToken.totalSupply();
            }

            else {
                revert("SingleState::_contribute: unidentified class");
            }

            uint balance = pool.reserve.balance;
        }
        
        // this will revert if parameters are insufficient as the math cannot be done with low values
        uint amountToMint = Utils.valueToMint(value, supply, balance);

        if (override_ == false) {
            if (fee.contribute >= 1) {
                uint feeAmount = amountToMint.mul(fee.contribute).div(10_000);
                amountToMint = amountToMint.sub(feeAmount);
                
                if (pool.class == decentralized || pool.class == hybrid) {
                    pool.governanceToken.mint(terminal, fee);

                } else if (pool.class = centralized) {
                    pool.standardToken.mint(terminal, fee);

                } else {
                    // if it got here and hasnt reverted already this is troubling
                    revert("SingleState::_contribute: unidentified class");
                }
            }
        }
        
        pool.reserve.balance += value;
        
        if (pool.class == decentralized || pool.class == hybrid) {
            pool.governanceToken.mint(msg.sender, amountToMint);
        } 

        else if (pool.class = centralized) {
            pool.standardToken.mint(msg.sender, amountToMint);
        } 
        
        else {
            // better safe than sorry i guess ...
            revert("SingleState::_contribute: unidentified class");
        }

        _overwritePool(no, pool);
        _overwriteAccount(msg.sender, caller);
    }

    /*---------------------------------------------------------------- WITHDRAW **/
    // internal function for withdraw
    // use no to select which pool
    // then the amount of that pool's tokens to burn in return for matic
    function _withdraw(uint no, uint amount, bool override_) internal payable nonReentrant {
        // in this context amount is the amount of the corresponding token being burnt
        require(
            amount >= 1,
            "SingleState::_withdraw(): amount < 1"
        );

        Pool memory pool = pools[no];

        // if past lock up period then can withdraw even if fundingSchedule is stil active
        // so setting funding schedule ending to 100 years doesnt cause a disaster
        bool isPastLockUpPeriod = block.timestamp >= pool.fundingSchedule.startTime.add(lockUpPeriod);

        if (!isPastLockUpPeriod) {
            bool isWithdrawalAllowed = !pool.fundingSchedule.success && (block.timestamp >= pool.fundingSchedule.startTime + pool.fundingSchedule.duration);

            require(
                isWithdrawalAllowed,
                "SingleState::_withdraw(): withdrawal is not allowed at this time"
            );
        }
        
        
        if (pool.class == decentralized || pool.class == hybrid) {
            uint supply = pool.governanceToken.totalSupply();
        } 

        else if (pool.class == centralized) {
            uint supply = pool.standardToken.totalSupply();
        }

        else {
            // first check. if this happens its likely because of a pool creation error
            revert("SingleState::_contribute: unidentified class");
        }

        uint balance = pool.reserve.balance;

        // this will revert if there is insufficient values to make the calculation
        uint amountToSend = Utils.burnToValue(amount, supply, balance);

        // this must never happen. but if it does revert and return their tokens to them
        require(
            pool.reserve.balance >= valueToSend,
            "SingleState::_withdraw(): insufficient balance on contract to make withdrawal"
        );

        if (override_ == false) {
            if (fee.withdraw >= 1) {
                uint feeAmount = amount.mul(fee.withdraw).div(10_000);
                valueToSend = valueToSend.sub(feeAmount);
                Address.sendValue(payable(terminal), fee);
            }
        }

        if (pool.class == decentralized || pool.class == hybrid) {
            uint supply = pool.governanceToken.burnFrom(msg.sender, amount);
        } 

        else if (pool.class == centralized) {
            uint supply = pool.standardToken.burnFrom(msg.sender, amount);
        }

        else {
            // again ... better safe than sorry ...
            revert("SingleState::_contribute: unidentified class");
        }

        // note storage update
        Address.sendValue(payable(msg.sender), valueToSend);
        pool.reserve.balance = pool.reserve.balance.sub(valueToSend);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN COMMANDS
    //////////////////////////////////////////////////////////////*/

}