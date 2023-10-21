// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract PoolableLite is StorageLite {

    event MintFeeUpdated(uint indexed previousFee, uint indexed newFee);

    event BurnFeeUpdated(uint indexed previousFee, uint indexed newFee);

    function mintFee() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____mintFee()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____mintFee()], (uint));
    }

    function burnFee() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____burnFee()]) == keccak256(emptyBytes)) {
            return 0;
        }
        return abi.decode(_bytes[____burnFee()], (uint));
    }

    function ____mintFee() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("MINT_FEE"));
    }

    function ____burnFee() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("BURN_FEE"));
    }

    function _amountToMint(uint v, uint s, uint b) internal view virtual returns (uint) {
        require(
            v != 0 &&
            s != 0 &&
            b != 0,
            "PoolableLite: zero value"
        );
        uint mint = ((v * s) / b);
        uint fee = (mint * mintFee()) / 10000;
        return mint - fee;
    }

    function _amountToSend(uint a, uint s, uint b) internal view virtual returns (uint) {
        require(
            a != 0 &&
            s != 0 &&
            b != 0,
            "PoolableLite: zero value"
        );
        uint send = ((a * b) / s);
        uint fee = (send * burnFee()) / 10000;
        return send - fee;
    }

    function _setMintFee(uint newFee) internal virtual {
        require(newFee <= 10000, "PoolableLite: out of bounds | > 10000");
        uint previousFee = mintFee();
        _bytes[____mintFee()] = abi.encode(newFee);
        emit MintFeeUpdated(previousFee, newFee);
    }

    function _setBurnFee(uint newFee) internal virtual {
        require(newFee <= 10000, "PoolableLite: out of bounds | > 10000");
        uint previousFee = burnFee();
        _bytes[____burnFee()] = abi.encode(newFee);
        emit BurnFeeUpdated(previousFee, newFee);
    }
}