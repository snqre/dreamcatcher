
/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neSafe.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neSafe.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;

contract stAdmin {
    bytes32 internal constant _ADMIN = keccak256('node.admin');

    struct StAdmin {
        address admin;
    }

    function admin() internal pure virtual returns (StAdmin storage s) {
        bytes32 location = _ADMIN;
        assembly {
            s.slot := location
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neSafe.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;

contract stSafe {
    bytes32 internal constant _SAFE = keccak256('node.safe');

    struct StSafe {
        uint requiredThreshold;
        uint numTrustee;
        StSafeRequest[] requests;
        mapping(address => bool) isTrustee;
    }

    struct StSafeRequest {
        address to;
        address tokenOut;
        uint amountOut;
        uint numSigned;
        bool done;
        mapping(address => bool) hasSigned;
    }

    function safe() internal pure virtual returns (StSafe storage s) {
        bytes32 location = _SAFE;
        assembly {
            s.slot := location
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neSafe.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.19;

////import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}




/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neSafe.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.19;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neSafe.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.19;
////import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
////import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';
////import 'contracts/polygon/plug-in/storage/stSafe.sol';
////import 'contracts/polygon/plug-in/storage/stAdmin.sol';

contract neSafe is Context, stSafe, stAdmin {
    event NewSafeRequest(address sender, address to, address tokenOut, uint amountOut, uint i);
    event SafeRequestSigned(address signer, uint numSigned, uint numTrustee, uint threshold, uint requiredThreshold);
    event SafeTransferred(address to, address tokenOut, uint amountOut, uint numSigned, uint numTrustee, uint threshold, uint requiredThreshold);
    event RoleGrantedTrustee(address account, uint numTrustee);
    event RoleRevokedTrustee(address account, uint numTrustee);
    event SafeRequiredThresholdChanged(uint oldThreshold, uint newThreshold);

    function getSafeTransferRequest(uint i) public view virtual returns (address to, address tokenOut, uint amountOut, uint numSigned, bool done) {
        to = safe().requests[i].to;
        tokenOut = safe().requests[i].tokenOut;
        amountOut = safe().requests[i].amountOut;
        numSigned = safe().requests[i].numSigned;
        done = safe().requests[i].done;
        return (to, tokenOut, amountOut, numSigned, done);
    }

    function getSafeTransferRequestThreshold(uint i) public view virtual returns (uint) {
        return (safe().requests[i].numSigned * 10000) / safe().numTrustee;
    }

    function setSafeRequiredThreshold(uint newThreshold) public virtual {
        require(_msgSender() == admin().admin, 'neSafe: only admin');
        require(newThreshold <= 10000, 'neSafe: out of bounds');
        uint oldThreshold = safe().requiredThreshold;
        safe().requiredThreshold = newThreshold;
        emit SafeRequiredThresholdChanged(oldThreshold, newThreshold);
    }

    function setSafeTrustee(address account, bool isTrustee) public virtual {
        require(_msgSender() == admin().admin, 'neSafe: only admin');
        safe().isTrustee[account] = isTrustee;
        if (isTrustee) {
            safe().numTrustee += 1;
            RoleGrantedTrustee(account, safe().numTrustee);
        } else {
            safe().numTrustee -= 1;
            RoleRevokedTrustee(account, safe().numTrustee);
        }
    }

    function requestSafeTransfer(address to, address tokenOut, uint amountOut) public virtual returns (uint) {
        require(safe().isTrustee[_msgSender()], 'neSafe: only trustee');
        StSafeRequest memory newRequest = StSafeRequest();
        newRequest.to = to;
        newRequest.tokenOut = tokenOut;
        newRequest.amountOut = amountOut;
        safe().requests.push(newRequest);
        uint i = safe().requests.length - 1;
        emit NewSafeRequest(_msgSender(), to, tokenOut, amountOut, i);
        return i;
    }

    function signSafeTransferRequest(uint i) public virtual {
        require(safe().isTrustee[_msgSender()], 'neSafe: only trustee');
        require(!safe().requests[i].hasSigned[_msgSender()], 'neSafe: cannot be signed again');
        safe().requests[i].hasSigned[_msgSender()] = true;
        safe().requests[i].numSigned += 1;
        emit SafeRequestSigned(_msgSender(), safe().requests[i].numSigned, safe().numTrustee, getSafeTransferRequestThreshold(i), safe().requiredThreshold);
    }

    function executeSafeTransferRequest(uint i) public virtual {
        require(safe().isTrustee[_msgSender()], 'neSafe: only trustee');
        require(getSafeTransferRequestThreshold(i) >= safe().requiredThreshold, 'neSafe: insufficient threshold');
        safe().requests.done = true;
        if (safe().requests.tokenOut == address(0)) {
            require(address(this).balance >= safe().requests[i].amountOut, 'neSafe: insufficient balance');
            payable(safe().requests[i].to).transfer(safe().requests[i].amountOut);
        } else {
            require(IERC20Metadata(safe().requests[i].tokenOut).balanceOf(address(this)) >= safe().requests[i].amountOut, 'neSafe: insufficient balance');
            IERC20Metadata(safe().requests[i].tokenOut).transfer(safe().requests[i].to, safe().requests[i].amountOut);
        }
        emit SafeTransferred(safe().requests[i].to, safe().requests[i].tokenOut, safe().requests[i].amountOut, safe().requests[i].numSigned, safe().numTrustee, getSafeTransferRequestThreshold(i), safe().requiredThreshold);
    }
}
