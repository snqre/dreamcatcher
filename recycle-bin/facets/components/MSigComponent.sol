// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

library MSigComponent {
    using RoleComponent for RoleComponent.Role;

    event SetUp(uint idx, address[] signers, uint sigThreshold, uint startTimestamp, uint timeout);
    event Signed(uint idx);
    event Passed(uint idx);

    struct MSig {
        uint _idx;
        uint _signatures;
        uint _sigThreshold;
        uint _startTimestamp;
        uint _timeout;
        bool _success;
        RoleComponent.Role _signers;
        mapping(address => bool) _hasSigned;
    }

    function idx(MSig storage msig) internal view returns (uint) {
        return msig._idx;
    }

    function signatures(MSig storage msig) internal view returns (uint) {
        return msig._signatures;
    }

    function sigThreshold(MSig storage msig) internal view returns (uint) {
        return msig._sigThreshold;
    }

    function startTimestamp(MSig storage msig) internal view returns (uint) {
        return msig._startTimestamp;
    }

    function timeout(MSig storage msig) internal view returns (uint) {
        return msig._timeout;
    }

    function success(MSig storage msig) internal view returns (bool) {
        return msig._success;
    }

    function signers(MSig storage msig, uint i) internal view returns (address) {
        return msig.role.members(i);
    }

    function signers(MSig storage msig) internal view returns (address[] memory) {
        return msig.role.members();
    }

    function signersLength(MSig storage msig) internal view returns (uint) {
        return msig.role.membersLength();
    }

    function set(MSig storage msig, RoleComponent.Role storage role, uint idx, uint sigThreshold, uint timeout) internal {
        msig._idx = idx;
        msig._signatures = 0;
        msig._startTimestamp = block.timestamp;
        msig._sigThreshold = sigThreshold;
        msig._timeout = timeout;
        msig._success = false;
        msig._signers = role;
        emit SetUp(msig._idx, msig._signers.members(), msig._sigThreshold, msig._startTimestamp, msig._timeout);
    }

    function sign(MSig storage msig) internal {
        msig._signers.authenticate();
        require(!msig._hasSigned(msg.sender), "MSigComponent: already signed");
        msig._signatures += 1;
        emit Signed(msig._idx);
        if ()
    }
}