// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/security/Pausable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/repository/IRepository.sol";

contract DreamToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit {
    IRepository public repository;
    address private _deployer;
    bool private _init;

    constructor(address repository_)
    ERC20("DreamToken", "DREAM")
    ERC20Permit("DreamToken") {
        repository = IRepository(repository_);
        _deployer = msg.sender;
        _init = false;
    }

    function getCurrentSnapshotId()
    external view
    returns (uint) {
        return _getCurrentSnapshotId();
    }

    function init()
    external {
        require(msg.sender == _deployer, "DreamToken: msg.sender != _deployer");
        require(!_init, "DreamToken: _init");
        bytes32 cap = keccak256(abi.encode("dreamToken", "cap"));
        bytes32 name_ = keccak256(abi.encode("dreamToken", "name"));
        bytes32 symbol_ = keccak256(abi.encode("dreamToken", "symbol"));
        bytes32 decimals_ = keccak256(abi.encode("dreamToken", "decimals"));
        repository.setString(name_, name());
        repository.setString(symbol_, symbol());
        repository.setUint(decimals_, decimals());
        uint amount = _convertToWei(200000000);
        repository.setUint(cap, amount);
        _mint(msg.sender, amount);
        _init = true;
    }

    function snapshot()
    external
    returns (uint index) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    function _convertToWei(uint value)
    internal pure
    returns (uint) {
        return value * 10**18;
    }

    function _beforeTokenTransfer(address from, address to, uint amount)
    internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
        bytes32 from_ = keccak256(abi.encode("dreamToken", from, "balance"));
        bytes32 to_ = keccak256(abi.encode("dreamToken", to, "balance"));
        bytes32 totalSupply_ = keccak256(abi.encode("dreamToken", "totalSupply"));
        bytes32 cap = keccak256(abi.encode("dreamToken", "cap"));
        uint bal;
        // minting
        if (from == address(0)) {
            bal = repository.getUint(to_);
            bal += amount;
            repository.setUint(to_, bal);
            bal = repository.getUint(totalSupply_);
            bal += amount;
            require(bal <= repository.getUint(cap), "DreamToken: cannot mint because supply is at capacity");
            repository.setUint(totalSupply_, bal);
        } else if (to == address(0)) { // burning
            bal = repository.getUint(from_);
            bal -= amount;
            repository.setUint(from_, bal);
            bal = repository.getUint(totalSupply_);
            bal -= amount;
            repository.setUint(totalSupply_, bal);
            bal = repository.getUint(cap);
            bal -= amount;
            repository.setUint(cap, bal);
        } else { // transfer
            bal = repository.getUint(from_);
            bal -= amount;
            repository.setUint(from_, bal);
            bal = repository.getUint(to_);
            bal += amount;
            repository.setUint(to_, bal);
        }
    }
}