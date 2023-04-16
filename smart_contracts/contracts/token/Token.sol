// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// RESTARTED, I THINK I CAN DO IT BETTER
// WE CANT USE OPENZEPPELIN BECAUSE THEY DONT ALLOW US TO FLEXIBLY EDIT
// BUT WILL BE BORROWING SOME OF THEIR BASE LINE FRAMEWORKS

/// @notice Token Contract
/// @dev It does token stuff and hurts my brain
/// @author Marco

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/IERC5805.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol";

/**
ERC20
# totalSupply()
# maxSupply() && cap()
# balanceOf(_owner)
# transfer(_to, _amount)
# allowance(_owner, _spender)
# approve(_spender, _amount)
# transferFrom(_from, _to, _amount)
# name()
# symbol()
# decimals()

PERMIT
# permit(_owner, _spender, _value, _deadline, _v, _r, s)
# nonces(_owner)
# DOMAIN_SEPARATOR()

 */

library Get {
    function msgSender() internal view returns (address) {return msg.sender;}
    function msgData() internal view returns (bytes calldata) {return msg.data;}
}

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}
interface IERC20Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IERC20Permit {
    function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external;
    function nonces(address _owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

contract Token is IERC20, IERC20Metadata {
    string   private immutable name_;
    string   private immutable symbol_;
    uint8    private decimals_;
    uint256  private totalSupply_;
    uint256  private immutable maxSupply_;
    mapping(address => uint256) private balances_;
    mapping(address => mapping(address => uint256)) private allowances_;

    constructor() {
        name_ = "Dreamcatcher";
        symbol_ = "DREAM";
        decimals_ = 18;
        totalSupply_ = 0;
        maxSupply_ = 200000000 * 10**decimals_;
    }

    // =.=.=.=.= ERC20 PUBLIC VIS
    function name() public view returns (string memory) {return name_;}
    function symbol() public view returns (string memory) {return symbol_;}
    function decimals() public view returns (uint8) {return decimals_;}
    function balanceOf(address _owner) public view returns (uint256) {return balances_[_owner];}
    function totalSupply() public view returns (uint256) {return totalSupply_;}
    function maxSupply() public view returns (uint256) {return maxSupply_;}
    function allowance(address _owner, address _spender) public view returns (uint256) {return allowances_[_owner][_spender];}
    function approve(address _spender, uint256 _amount) public returns (bool) {
        address owner = Get.msgSender();
        require(owner != address(0), "Approve from the zero address");
        require(_spender != address(0), "Approve from the zero address");
        allowances_[owner][_spender] = _amount;
        emit Approval(owner, _spender, _amount);
        return true;
    }
    function transfer(address _to, uint256 _amount) public returns (bool) {
        address memory _from = Get.msgSender();
        require(_from != address(0), "Transfer from the zero address");
        require(_to != address(0), "Transfer to the zero address");
        beforeTokenTransfer(_from, _to, _amount);
        require(balances_[_from] >= _amount, "Transfer amount exceeds balance");
        unchecked {
            balances_[_from] -= _amount;
            balances_[_to] += _amount;
        }
        emit Transfer(_from, _to, _amount);
        afterTokenTransfer(_from, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        address _spender = Get.msgSender();
        uint256 currentAllowance = allowance(_from, _spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _amount, "Insufficient allowance");
            unchecked {
                require(_from != address(0), "Approve from the zero address");
                require(_spender != address(0), "Approve to the zero address");
                allowances_[_from][_spender] = _amount;
                emit Approval(_from, _spender, _amount);
            }
        }
        require(_from != address(0), "Transfer from the zero address");
        require(_to != address(0), "Transfer to the zero address");
        beforeTokenTransfer(_from, _to, _amount);
        require(balances_[_from] >= _amount, "Transfer amount exceeds balance");
        unchecked {
            balances_[_from] -= _amount;
            balances_[_to] += _amount;
        }
        emit Transfer(_from, _to, _amount);
        afterTokenTransfer(_from, _to, _amount);
        return true;
    }
    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        address _owner = Get.msgSender();
        require(_owner != address(0), "Approve from the zero address");
        require(_spender != address(0), "Approve to the zero address");
        allowances_[_owner][_spender] = allowance(_owner, _spender) + _addedValue;
        emit Approval(_owner, _spender, allowance(_owner, _spender) + _addedValue);
        return true;
    }
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        address _owner = Get.msgSender();
        uint256 currentAllowance = allowance(_owner, _spender);
        require(currentAllowance >= _subtractedValue, "Decrease allowance below zero");
        unchecked {
            require(_owner != address(0), "Approve from the zero address");
            require(_spender != address(0), "Approve to the zero address");
            allowances_[_owner][_spender] = currentAllowance - _subtractedValue;
            emit Approval(_owner, _spender, currentAllowance - _subtractedValue);
        }
        return true;
    }
    // =.=.=.=.= ERC20 INTERNAL VIS
    function increase
    function mint(address _to, uint256 _amount) internal {
        require(totalSupply_ + _amount <= maxSupply_, "Max supply exceeded");
        require(_to != address(0), "Mint to the zero address");
        beforeTokenTransfer(address(0), _to, _amount);
        unchecked {balances_[_to] += _amount;}
        totalSupply_ += _amount;
        emit Transfer(address(0), _to, _amount);
        afterTokenTransfer(address(0), _to, _amount);
    }
    function burn(address _from, uint256 _amount) internal {
        require(_from != address(0), "Burn from the zero address");
        beforeTokenTransfer(_from, address(0), _amount);
        require(balances_[_from] >= _amount, "Burn amount exceeds balance");
        unchecked {
            balances_[_from] -= _amount;
            totalSupply_ -= _amount;
        }
        emit Transfer(_from, address(0), _amount);
        afterTokenTransfer(_from, address(0), _amount);
    }
    function beforeTokenTransfer(address _from, address _to, uint256 _amount) internal {}
    function afterTokenTransfer(address _from, address _to, uint256 _amount) internal {}
}

contract Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) internal nonces_;
}

contract Token is IERC5805{
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }
    bytes32 private constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    mapping(address => address) private delegates_;
    mapping(address => Checkpoint[]) private checkpoints_;
    Checkpoint[] private totalSupplyCheckpoints;
    
    /**/function clock() public view virtual override returns (uint48) {
            return SafeCast.toUint48(block.number);
        }

    /**/function CLOCK_MODE() public view virtual override returns (string memory) {
            require(clock() == block.number);
            return "mode=blocknumber&from=default";
        }

    /**/function checkpoints(address _owner, uint32 _pos) public view virtual returns (Checkpoint memory) {
            return checkpoints_[_owner][_pos];
        }
    
    /**/function numCheckpoints(address _owner) public view virtual returns (uint32) {
            return SafeCast.toUint32(checkpoints_[_owner].length);
        }

    /**/function delegates(address _owner) public view virtual override returns (address) {
            return delegates_[_owner];
        }

    /**/function getVotes(address _owner) public view virtual override returns (uint256) {
            uint256 pos = checkpoints_[_owner].length;
            unchecked {
                return pos == 0 ? 0 : checkpoints_[_owner][pos - 1].votes;
            }
        }
    
    /**/function getPastVotes(address _owner, uint256 _timepoint) public view virtual override returns (uint256) {
            require(_timepoint < clock(), "ERC20Votes: future lookup");
            return checkpointsLookup(checkpoints_[_owner], _timepoint);
        }
    
    /**//**/function checkpointsLookup(Checkpoint[] storage _ckpts, uint256 _timepoint) private view returns (uint256) {

    }



}


contract Token is IERC20, ERC20Permit, EIP712, IERC5805 {
    // var_ :: because function names conflict with ERC20 get functions
    bytes private name_;
    bytes private symbol_;
    uint256 private totalSupply_;
    uint256 private immutable maxSupply_;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // ERC20 PERMIT
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) private nonces_;
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 private PERMIT_TYPEHASH_DEPRECATED_SLOT;

    // VOTES
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }
    bytes32 private constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    mapping(address => address) private delegates_;
    mapping(address => Checkpoint[]) private checkpoints_;
    Checkpoint[] private totalSupplyCheckpoints;

    constructor() EIP712(LibToken.getBytesAsString("Dreamcatcher", "1")) {
        name_ = LibToken.setStringAsBytes("Dreamcatcher");
        symbol_ = LibToken.setStringAsBytes("DREAM");
        totalSupply_ = 0;
        maxSupply_ = 200000000 * 10**18; // 200 million
    }

    // VOTES
    function clock() public view returns (uint48) {
        return SafeCast.toUint48(block.number);
    }

    function CLOCK_MODE() public view returns (string memory) {
        require(clock() == block.number);
        return "mode=blocknumber&from=default";
    }

    function checkpoints(address _owner, uint32 _pos)
        public
        view
        returns (Checkpoint memory)
    {
        return checkpoints[_owner][_pos];
    }

    function numCheckpoints(address _owner) public view returns (uint32) {
        return SafeCast.toUint32(checkpoints[_owner].length);
    }

    function delegates(address _owner) public view returns (address) {
        return delegates[_owner];
    }

    function getVotes(address _owner) public view returns (uint256) {
        uint256 pos = checkpoints[_owner].length;
        unchecked {
            return pos == 0 ? 0 : checkpoints[_owner][pos - 1].votes;
        }
    }

    function getPastVotes(address _owner, uint256 _timepoint)
        public
        view
        returns (uint256)
    {
        require(_timepoint < clock(), "future lookup");
        return checkpointsLookUp(checkpoints[_owner], _timepoint);
    }

    function getPastTotalSupply(uint256 _timepoint)
        public
        view
        returns (uint256)
    {
        require(_timepoint < clock(), "future lookup");
        return checkpointsLookUp(totalSupplyCheckpoints, _timepoint);
    }

    function delegateBySig(
        address _delegatee,
        uint256 _nonce,
        uint256 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(block.timestamp <= _expiry, "signature expired");
        address signer = ECDSA.recover(
            _hashTypedDataV4(
                keccak256(
                    abi.encode(DELEGATION_TYPEHASH, _delegatee, _nonce, _expiry)
                )
            ),
            _v,
            _r,
            _s
        );
        require(_nonce == useNonce(signer), "invalid nonce");
        delegate(signer, _delegatee);
    }

    function checkpointsLookUp(Checkpoint[] storage ckpts, uint256 _timepoint)
        private
        view
        returns (uint256)
    {
        uint256 length = ckpts.length;
        uint256 low = 0;
        uint256 high = length;
        if (length > 5) {
            uint256 mid = length - Math.sqrt(length);
            if (unsafeAccess(ckpts, mid).fromeBlock > _timepoint) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (unsafeAccess(ckpts, mid).fromBlock > _timepoint) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        unchecked {
            return high == 0 ? 0 : unsafeAccess(ckpts, high - 1).votes;
        }
    }

    function delegate(address _delegator, address _delegatee) internal {
        address currentDelegate = delegates(_delegator);
        uint256 delegatorBalance = balanceOf(_delegator);
        delegates[_delegator] = _delegatee;
        emit DelegateChanged(_delegator, currentDelegate, _delegatee);
        moveVotingPower(currentDelegate, _delegatee, delegatorBalance);
    }

    function moveVotingPower(
        address _src,
        address _dst,
        uint256 _amount
    ) private {
        if (_src != _dst && _amount > 0) {
            if (_src != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = writeCheckpoint(
                    checkpoints[_src],
                    subtract,
                    _amount
                );
                emit DelegateVotesChanged(_src, oldWeight, newWeight);
            }

            if (_dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = writeCheckpoint(
                    checkpoints[_dst],
                    add,
                    _amount
                );
                emit DelegateVotesChanged(_dst, oldWeight, newWeight);
            }
        }
    }

    function writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        unchecked {
            Checkpoint memory oldCkpt = pos == 0
                ? Checkpoint(0, 0)
                : unsafeAccess(ckpts, pos - 1);
            oldWeight = oldCkpt.votes;
            newWeight = op(oldWeight, delta);
            if (pos > 0 && oldCkpt.fromBlock == clock()) {
                unsafeAccess(ckpts, pos - 1).votes = SafeCast.toUint244(
                    newWeight
                );
            } else {
                ckpts.push(
                    Checkpoint({
                        fromBlock: SafeCast.toUint32(clock()),
                        votes: SafeCast.toUint244(newWeight)
                    })
                );
            }
        }
    }

    function add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

    function unsafeAccess(Checkpoint[] storage ckpts, uint256 _pos)
        private
        pure
        returns (Checkpoint storage result)
    {
        assembly {
            mstore(0, ckpts.slot)
            result.slot := add(keccak256(0, 0x20), _pos)
        }
    }

    // PERMIT
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(block.timestamp <= _deadline, "expired deadline");
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                _owner,
                _spender,
                _value,
                useNonce(_owner),
                _deadline
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, _v, _r, _s);
        require(signer == _owner, "invalid signature");
        // approve function from erc20 owner, spender, value
        require(_owner != address(0), "approve from the zero address");
        require(_spender != address(0), "approve to the zero address");
        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    // VOTES
    // PERMIT
    function nonces(address _owner) public view returns (uint256) {
        return nonces[_owner].current();
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function useNonce(address _owner) internal returns (uint256 current) {
        Counters.Counter storage nonce = nonces[_owner];
        current = nonce.current();
        nonce.increment();
    }

    // ERC20
    function maxSupply() public view returns (uint256) {
        return maxSupply_;
    } // a function name that actually makes sense

    function cap() public view returns (uint256) {
        return maxSupply_;
    } // openzeppelin format for those expecting openzeppelin

    function name() public view returns (string memory) {
        return LibToken.getBytesAsString(name_);
    }

    function symbol() public view returns (string memory) {
        return LibToken.getBytesAsString(symbol_);
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        address from = LibToken.msgSender();
        require(from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        beforeTokenTransfer(from, _to, _amount);
        require(balances[from] >= _amount, "transfer amount exceeds balance");
        unchecked {
            balances[from] -= _amount;
            balances[_to] += _amount;
        }
        emit Transfer(from, _to, _amount);
        afterTokenTransfer(from, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        address owner = LibToken.msgSender();
        require(owner != address(0), "approve from the zero address");
        require(_spender != address(0), "approve to the zero address");
        allowances[owner][_spender] = _amount;
        emit Approval(owner, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        address spender = LibToken.msgSender();
        // spend allowance from, spender, amount
        uint256 currentAllowance = allowance(_from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _amount, "insufficient allowance");
            unchecked {
                // owner, spender, currentAllowance - amount
                require(_from != address(0), "approve from the zero address");
                require(spender != address(0), "approve to the zero address");
                allowances[_from][spender] = _amount;
                emit Approval(_from, spender, _amount);
            }
        }
        // transfer from, to, amount
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");
        beforeTokenTransfer(_from, _to, _amount);
        require(balances[_from] >= _amount, "transfer amount exceeds balance");
        unchecked {
            balances[_from] -= _amount;
            balances[_to] += _amount;
        }
        emit Transfer(_from, _to, _amount);
        afterTokenTransfer(_from, _to, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {
        address owner = LibToken.msgSender();
        // owner, spender, allowance(owner, spender) + addedValue
        require(owner != address(0), "approve from the zero address");
        require(_spender != address(0), "approve to the zero address");
        uint256 amount = allowance(owner, _spender) + _addedValue;
        allowances[owner][_spender] = amount;
        emit Approval(owner, _spender, amount);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {
        address owner = LibToken.msgSender();
        uint256 currentAllowance = allowance(owner, _spender);
        require(
            currentAllowance >= _subtractedValue,
            "decrease allowance below zero"
        );
        unchecked {
            // owner | spender | currentAllowance - subtractedValue
            require(owner != address(0), "approve from the zero address");
            require(_spender != address(0), "approve to the zero address");
            uint256 amount = currentAllowance - _subtractedValue;
            allowances[owner][_spender] = amount;
            emit Approval(owner, _spender, amount);
        }
        return true;
    }

    // merged ERC20 && ERC20Capped
    function mint(address _to, uint256 _amount) internal {
        require(totalSupply() + _amount <= maxSupply(), "cap exceeded");
        require(_to != address(0), "mint to the zero address");
        beforeTokenTransfer(address(0), _to, _amount);
        totalSupply_ += _amount;
        unchecked {
            balances[_to] += _amount;
        }
        emit Transfer(address(0), _to, _amount);
        afterTokenTransfer(address(0), _to, _amount);
        writeCheckpoint(totalSupplyCheckpoints, add, _amount);
    }

    function burn(address _from, uint256 _amount) internal {
        require(_from != address(0), "burn from the zero address");
        beforeTokenTransfer(_from, address(0), _amount);
        require(balances[_from] >= _amount, "burn amount exceeds balance");
        unchecked {
            balances[_from] -= _amount;
            totalSupply_ -= _amount;
        }
        emit Transfer(_from, address(0), _amount);
        afterTokenTransfer(_from, address(0), _amount);
        writeCheckpoint(totalSupplyCheckpoints, subtract, _amount);
    }

    // before transfers
    function beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal {}

    // after transfers
    function afterTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        moveVotingPower(delegates(_from), delegates(_to), _amount);
    }
}
