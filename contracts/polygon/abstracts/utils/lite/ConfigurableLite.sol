// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstracts/storage/StorageLite.sol";
import "contracts/polygon/external/openzeppelin/utils/Context.sol";

abstract contract ConfigurableLite is StorageLite, Context {
    
    event Configured(address indexed sender);

    /** 
    * @dev In this case we dont set the value within an initialize function
    *      because this is only intended to be called once and never touched again
    *      so we just interpret the empty data as false. _configure should be the first function
    *      that is called in the proxy.
     */
    function configured() public view virtual returns (bool) {
        bytes memory emptyBytes;
        if (keccak256(_bytes[____configured()]) == keccak256(emptyBytes)) {
            return false;
        }
        return abi.decode(_bytes[____configured()], (bool));
    }

    function ____configured() internal pure virtual returns (bytes32) {
        return keccak256(abi.encode("CONFIGURED"));
    }

    function _mustBeConfigured() internal view virtual {
        require(configured(), "ConfigurableLite: must be configured");
    }

    function _mustNotBeConfigured() internal view virtual {
        require(!configured(), "ConfigurableLite: cannot be configured again");
    }

    function _configure() internal virtual {
        _mustNotBeConfigured();
        _bytes[____configured()] = abi.encode(true);
        emit Configured(_msgSender());
    }
}