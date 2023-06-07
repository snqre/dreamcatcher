// work in progress

contract StandardToken is ERC2O, ERC20Burnable, ERC20Permit, AccessControl {
    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Permit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(to, amount);
    }
}