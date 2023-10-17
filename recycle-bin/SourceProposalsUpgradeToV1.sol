// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "contracts/polygon/external/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/libraries/__Shared.sol";
import "contracts/polygon/ProxyStateOwnableContract.sol";
import "contracts/polygon/interfaces/IProposalUpgradeToV1.sol";
import "contracts/polygon/interfaces/IProposalCallV1.sol";
import "contracts/polygon/ProposalUpgradeToV1.sol";
import "contracts/polygon/ProposalCallV1.sol";

contract ProposalFactoryV1 is ProxyStateOwnableContract {
    using EnumerableSet for EnumerableSet.AddressSet;

    event PermissionGranted(address indexed account);

    event PermissionRevoked(address indexed account);

    event TerminalV2SetTo(address indexed account);

    event Reinitialized();

    error AlreadyCouncil(address indexed account);

    error NotCouncil(address indexed account);

    error Unauthorized(address indexed account);

    function council() public view returns (address[] memory) {
        return _addressSet[keccak256(abi.encode("council"))].values();
    }

    function councilLength() public view returns (uint256) {
        return _addressSet[keccak256(abi.encode("council"))].length();
    }

    function isCouncil(address account) public view returns (bool) {
        return _addressSet[keccak256(abi.encode("council"))].contains(account);
    }

    function terminalV2() public view returns (address) {
        return _address[keccak256(abi.encode("terminalV2"))];
    }

    function mSigDuration() public view returns (uint64) {
        return _uint256[keccak256(abi.encode("mSigDuration"))];
    }

    function pSigDuration() public view returns (uint64) {
        return _uint256[keccak256(abi.encode("pSigDuration"))];
    }

    function timelockDuration() public view returns (uint64) {
        return _uint256[keccak256(abi.encode("timelockDuration"))];
    }

    function mSigRequiredQuorum() public view returns (uint256) {
        return _uint256[keccak256(abi.encode("mSigRequiredQuorum"))];
    }

    function pSigRequiredQuorum() public view returns (uint256) {
        return _uint256[keccak256(abi.encode("pSigRequiredQuorum"))];
    }

    function threshold() public view returns (uint256) {
        return _uint256[keccak256(abi.encode("threshold"))];
    }

    function update() public onlyOwner() {
        _setTerminalV2(0xd59431E364531e9f627c4B8065Ed13b62326810b);
        emit Reinitialized();
    }

    function proposeUpdate(string memory caption, string memory message, address proxyAddress, address proposedImplementation) public {
        new ProposalUpgradeToV1(
            caption,
            message,
            msg.sender,
            mSigDuration(),
            pSigDuration(),
            timelockDuration(),
            council(),
            mSigRequiredQuorum(),
            pSigRequiredQuorum(),
            threshold(),
            proxyAddress,
            proposedImplementation
        );
    }

    function proposeUpgradeTerminal()

    function proposeCall()

    function _onlyCouncil() internal view {
        if (!isCouncil(msg.sender)) { revert Unauthorized(msg.sender); }
    }

    function _grant(address account) internal {
        if (isCouncil(account)) { revert AlreadyCouncil(account); }
        _addressSet[keccak256(abi.encode("council"))].add(account);
        emit PermissionGranted(account);
    }

    function _revoke(address account) internal {
        if (!isCouncil(account)) { revert NotCouncil(account); }
        _addressSet[keccak256(abi.encode("council"))].remove(account);
        emit PermissionRevoked(account);
    }

    function _setTerminalV2(address account) internal {
        _address[keccak256(abi.encode("terminalV2"))] = account;
        emit TerminalV2SetTo(account);
    }
}