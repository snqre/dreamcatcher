// work in progress

contract GovernanceToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, AccessControl {
    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERCPermit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function snapshot() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _snapshot();
    }

    function mint(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function getVotes(address account) public view returns (uint256) {
        return balanceOfAt(account, _getCurrentSnapshotId());
    }

    function getPastVotes(address account, uint256 snapshotId) public view returns (uint256) {
        return balanceOfAt(account, snapshotId);
    }
}