// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/interfaces/oracle/price/IUniswapV2PriceFeed.sol";
import "contracts/polygon/abstracts/storage/StorageLite.sol";

abstract contract OracleAdaptorLite is StorageLite {

    event AdaptorAdded(address indexed adaptor);

    event AdaptorRemoved(address indexed adaptor);

    event AdaptorsSizeUpdated(uint indexed previousSize, uint indexed newSize);

    function adaptors(uint i) public view virtual returns (address) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____adaptors()]) == keccak256(emptyBytes)) {
            return address(0);
        }
        address[] memory set = new address[](adaptorsSize());
    }

    function adaptorsSize() public view virtual returns (uint) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[__]))
    }

    function ____adaptors() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("ADAPTORS"));
    }

    function ____adaptorsSize() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("ADAPTORS_SIZE"));
    }

    function _setAdaptorSize(uint newSize) internal virtual {
        uint previousSize = adaptorsSize();
        _bytes[____adaptorsSize()] = abi.encode(newSize);
        emit AdaptorsSizeUpdated(previousSize, newSize);
    }

    
}