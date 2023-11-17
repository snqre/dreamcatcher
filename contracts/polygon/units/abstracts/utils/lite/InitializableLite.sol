// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract InitializableLite is StorageLite, Context {

    event Initialized(address indexed sender);

    /** 
    * @dev In this case we dont set the value within an initialize function
    *      because this is only intended to be called once and never touched again
    *      so we just interpret the empty data as false. _configure should be the first function
    *      that is called in the proxy.
     */
    function initialized() public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____initialized()]) == keccak256(emptyBytes)) {
            return false;
        }
        return abi.decode(_bytes[____initialized()], (bool));
    }

    function ____initialized() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("INITIALIZED"));
    }

    function _mustBeInitialized() internal view virtual {
        require(initialized(), "InitializableLite: must be initialized");
    }

    function _mustNotBeInitialized() internal view virtual {
        require(!initialized(), "InitializableLite: cannot be initialized again");
    }

    function _initialize() internal virtual {
        _mustNotBeInitialized();
        _bytes[____initialized()] = abi.encode(true);
        emit Initialized(_msgSender());
    }
}