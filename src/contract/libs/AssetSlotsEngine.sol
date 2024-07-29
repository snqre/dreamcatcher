// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;

contract AssetSlotsEngine {
    address[] internal _slots;

    constructor(address[] memory slots) {
        _slots = slots;
    }
}