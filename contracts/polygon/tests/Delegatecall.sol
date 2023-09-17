// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "contracts/polygon/abstract/ProxyState.sol";

import "contracts/polygon/abstract/State.sol";

interface IFace {
    function check() external view returns (uint256);

    function mul(uint256 amount) external;

    function div(uint256 amount) external;

    function sub(uint256 amount) external;

    function add(uint256 amount) external;
}

contract Caller {
    address addressToCall;

    constructor(address addressToCall_) {
        addressToCall = addressToCall_;
    }

    function check() external view returns (uint256) {
        return IFace(addressToCall).check();
    }

    function mul(uint256 amount) external {
        IFace(addressToCall).mul(amount);
    }

    function div(uint256 amount) external {
        IFace(addressToCall).div(amount);
    }

    function sub(uint256 amount) external {
        IFace(addressToCall).sub(amount);
    }

    function add(uint256 amount) external {
        IFace(addressToCall).add(amount);
    }
}

contract Face is ProxyState {
    function upgrade(address implementation) external {
        _upgrade(implementation);
    }
}

contract ImplementationA is State {
    function check() external view returns (uint256) {
        bytes32 location = keccak256(abi.encode("storage"));
        return _uint256[location];
    }

    function sub(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] -= amount;
    }

    function add(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] += amount;
    }
}

contract ImplementationB is State {
    function check() external view returns (uint256) {
        bytes32 location = keccak256(abi.encode("storage"));
        return _uint256[location];
    }

    function sub(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] -= amount;
    }

    function add(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] += amount;
    }

    /** Here we add new functions in the implementation */
    function mul(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] *= amount;
    }

    function div(uint256 amount) external {
        bytes32 location = keccak256(abi.encode("storage"));
        _uint256[location] /= amount;
    }
}