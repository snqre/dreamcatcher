// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
import 'contracts/polygon/deps/openzeppelin/token/ERC20/extensions/IERC20Metadata.sol';
import 'contracts/polygon/plug-in/storage/stSafe.sol';
import 'contracts/polygon/plug-in/storage/stAdmin.sol';

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