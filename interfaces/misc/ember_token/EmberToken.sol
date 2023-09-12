// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/repository/IRepository.sol";

contract EmberToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    IRepository public repository;
    address private _deployer;
    bool private _init;

    constructor(address repository_)
    ERC2O("EmberToken", "EMBER")
    ERC20Permit("EmberToken") {
        
    }
}