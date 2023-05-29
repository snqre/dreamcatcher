// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Token is
ERC20,
ERC20Burnable,
ERC20Snapshot,
Ownable,
ERC20Permit,
ERC20Votes {

    constructor(
        string memory name,
        string memory symbol
    ) ERC20(
        name,
        symbol
    ) ERC20Permit(
        name
    ) Ownable() {}

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Snapshot
    ) {

        super._beforeTokenTransfer(
            from,
            to,
            amount
        );

    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {

        super._afterTokenTransfer(
            from,
            to,
            amount
        );

    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {

        super._mint(
            to,
            amount
        );

    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(
        ERC20,
        ERC20Votes
    ) {

        super._burn(
            account,
            amount
        );

    }

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function snapshot() public onlyOwner {

        _snapshot();

    }

    function mint(
        address to,
        uint256 amount
    ) public onlyOwner {

        _mint(
            to,
            amount
        );

    }

    function burn(
        address account,
        uint256 amount
    ) public onlyOwner {

        _burn(
            account,
            amount
        );

    }

    function renounceOwnership() public override onlyOwner {

        super.renounceOwnership();

    }

    function transferOwnership(
        address newOwner
    ) public override onlyOwner {

        super.transferOwnership(
            newOwner
        );

    }

}

interface ISingleState {

    event NewFundCreated(
        uint256 no,
        address indexed creator,
        string name,
        address[] managers,
        address token,
        string tokenName,
        string tokenSymbol,
        uint256 balance,
        uint256 initialSupply
    );

}

contract SingleState is
Initializable,
PausableUpgradeable,
OwnableUpgradeable {

    uint256 priceToCreateNewFund;
    uint256 feeToContribute;
    uint256 feeToWithdraw;

    uint256 numberOfPools;

    struct CollatTSchedule {

        uint64 startTimestamp;
        uint32 duration;
        uint256 guarantee;
        bool complete;

    }

    struct FundingSchedule {

        uint64 startTimestamp;
        uint32 duration;
        uint256 required;
        bool isWhitelisted;
        bool success;

    }

    struct Fund {

        uint256 no;
        string name;
        uint256 balance;
        address[] contracts;
        uint256[] amounts;
        Token token;
        FundingSchedule fundingSchedule;
        CollatTSchedule[] collatTSchedules;

    }

    mapping(
        uint256
        => Fund
    ) internal funds;

    struct Account {

        bool[] isAdmin;
        bool[] isCreator;
        bool[] isManager;
        bool[] isOnWhitelist;

    }

    mapping(
        address
        => Account
    ) internal accounts;

    constructor() {

        _disableInitializers();

    }

    /** required for openzeppelin upgradable */
    function initialize() initializer public {

        __Pausable_init();
        __Ownable_init();

    }

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function _convertToWei(
        uint256 value
    ) internal returns (
        uint256
    ) {

        return value * 10**18;

    }

    function _isAdminOf(
        uint256 no
    ) internal returns (
        bool
    ) {

        Account memory caller = accounts[
            msg.sender
        ];

        if (
            caller.isAdmin[
                no
            ]
        ) {

            return true;
            
        } else {

            return false;

        }

    }

    function _isCreatorOf(
        uint256 no
    ) internal returns (
        bool
    ) {

        Account memory caller = accounts[
            msg.sender
        ];

        if (
            caller.isCreator[
                no
            ]
        ) {

            return true;

        } else {

            return false;

        }

    }

    function _isManagerOf(
        uint256 no
    ) internal returns (
        bool
    ) {

        Account memory caller = accounts[
            msg.sender
        ];

        if (
            caller.isManager[
                no
            ]
        ) {

            return true;

        } else {

            return false;

        }

    }

    function _isOnWhitelistOf(
        uint256 no
    ) internal returns (
        bool
    ) {

        Account memory caller = accounts[
            msg.sender
        ];

        if (
            caller.isOnWhitelist[
                no
            ]
        ) {

            return true;

        } else {

            return false;

        }

    }

    function _createNewFund(
        uint256 no,
        string memory name,
        uint256 balance,
        address[] memory managers,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        uint64 startTimestamp,
        uint32 duration,
        uint256 required,
        bool isWhitelisted
    ) internal returns (
        Fund
    ) {

        Fund newFund = Fund({
            no: no,
            name: name,
            balance: balance,
            token: new Token(
                tokenName,
                tokenSymbol
            ),
            FundingSchedule({
                startTimestamp: startTimestamp,
                duration: duration,
                required: required,
                isWhitelisted: isWhitelisted,
                success: false
            }),
            callatTSchedules: CollatTSchedule[]
        });

        for (
            uint256 i = 0; i < managers.length; i++
        ) {

            Account memory caller = accounts[
                managers[
                    i
                ]
            ];

            caller.isManager[
                no
            ] = true;

            accounts[
                msg.sender
            ] = caller;

        }

        emit NewFundCreated(
            no,
            msg.sender,
            managers,
            address(
                newFund.token
            ),
            tokenName,
            tokenSymbol,
            balance,
            initialSupply
        )

        return newFund;
    }

    function _contributeTo(
        uint256 no
    ) internal {

        /** ... contribute to ... */

    }

    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */



    /** -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.- */
    function createNewFund(
        string memory name,
        address[] memory managers,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        uint32 duration,
        uint256 required,
        bool isWhitelisted
    ) public payable returns (
        bool
    ) {

        require(
            managers.length
            >= 1,
            "SingleState::createNewFund(): managers.length < 1"
        );

        require(
            managers.length
            <= 9,
            "SingleState::createNewFund(): managers.length > 9"
        );

        require(
            initialSupply
            >= _convertToWei(
                1
            ),
            "SingleState::createNewFund(): initialSupply < 1 * 10**18"
        );

        require(
            duration
            >= 24 hours,
            "SingleState::createNewFund(): duration < 24 hours"
        );

        require(
            duration
            <= 48 weeks,
            "SingleState::createNewFund(): duration > 48 weeks"
        );

        require(
            required
            >=0,
            "SingleState::createNewFund(): required < 0"
        );
        
        require(
            msg.value
            >= 100000,
            "SingleState::createNewFund(): msg.value < 100000"
        );

        numberOfPools += 1

        uint256 now_ = block.timestamp;

        _createNewFund(
            numberOfPools,
            name,
            msg.value,
            managers,
            tokenName,
            tokenSymbol,
            initialSupply,
            now_,
            duration,
            required,
            isWhitelisted
        );

    }

}