// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/polygon/diamonds/facets/components/RoleComponent.sol";

library TokenComponent {
    using RoleComponent for RoleComponent.Role;

    event Transfer(address from, address to, uint amount);
    event Approval(address owner, address spender, uint amount);

    struct Token {
        mapping(address => uint) _balances;
        mapping(address => mapping(address => uint)) _allowances;
        uint _totalSupply;
        string _name;
        string _symbol;
    }

    function name(Token storage token) internal view returns (string memory) {
        return token._name;
    }

    function symbol(Token storage token) internal view returns (string memory) {
        return token._symbol;
    }

    function decimals(Token storage token) internal view returns (uint8) {
        return 18;
    }

    function totalSupply(Token storage token) internal view returns (uint) {
        return token._totalSupply;
    }

    function balanceOf(Token storage token, address account) internal view returns (uint) {
        return token._balances[account];
    }

    function allowance(Token storage token, address owner, address spender) internal view returns (uint) {
        return token._allowances[owner][spender];
    }

    function transfer(Token storage token, RoleComponent.Role storage role, address to, uint amount) internal returns (bool) {
        role.tryAuthenticate();
        address owner = msg.sender;
        _transfer(token, owner, to, amount);
        return true;
    }

    function mint(Token storage token, RoleComponent.Role storage role, address account, uint amount) internal {
        role.authenticate();
        _mint(token, account, amount);
    }

    function burn(Token storage token, RoleComponent.Role storage role, uint amount) internal {
        role.tryAuthenticate();
        address owner = msg.sender;
        _burn(token, owner, amount);
    }

    function burnFrom(Token storage token, RoleComponent.Role storage role, address account, uint amount) internal {
        role.tryAuthenticate();
        _spendAllowance(token, account, msg.sender, amount);
        _burn(account, amount);

    }

    function approve(Token storage token, RoleComponent.Role storage role, address spender, uint amount) internal returns (bool) {
        role.tryAuthenticate();
        address owner = msg.sender;
        _approve(token, owner, spender, amount);
        return true;
    }

    function transferFrom(Token storage token, RoleComponent.Role storage role, address from, address to, uint amount) internal returns (bool) {
        role.tryAuthenticate();
        address spender = msg.sender;
        _spendAllowance(token, from, spender, amount);
        _transfer(token, from, to, amount);
        return true;
    }

    function increaseAllowance(Token storage token, RoleComponent.Role storage role, uint addedValue) internal returns (bool) {
        role.tryAuthenticate();
        address owner = msg.sender;
        _approve(token, owner, spender, allowance(token, owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(Token storage token, RoleComponent.Role storage role, address spender, uint subtractedValue) internal returns (bool) {
        role.tryAuthenticate();
        address owner = msg.sender;
        uint currentAllowance = allowance(token, owner, spender);
        require(currentAllowance >= subtractedValue, "TokenComponent: decreased allowance below zero");
        unchecked {
            _approve(token, owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(Token storage token, address from, address to, uint amount) private {
        require(from != address(0), "TokenComponent: transfer from the zero address");
        require(to != address(0), "TokenComponent: transfer to the zero address");
        _beforeTokenTransfer(token, from, to, amount);
        uint fromBalance = token._balances[from];
        require(fromBalance >= amount, "TokenComponent: transfer amount exceeds balance");
        unchecked {
            token._balances[from] = fromBalance - amount;
            token._balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(Token storage token, address account, uint amount) private {
        require(account != address(0), "TokenComponent: mint to the zero address");
        _beforeTokenTransfer(token, address(0), account, amount);
        token._totalSupply += amount;
        unchecked {
            token._balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(token, address(0), account, amount);
    }

    function _burn(Token storage token, address account, uint amount) private {
        require(account != address(0), "TokenComponent: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint accountBalance = token._balances[account];
        require(accountBalance >= amount, "TokenComponent: burn amount exceeds balance");
        unchecked {
            token._balances[account] = accountBalance - amount;
            token._totalSupply -= amount;
        }
        emit Tranfer(account, address(0), amount);
        _afterTokenTransfer(token, account, address(0), amount);
    }

    function _approve(Token storage token, address spender, uint amount) private {
        require(owner != address(0), "TokenComponent: approve from the zero address");
        require(spender != address(0), "TokenComponent: approve to the zero address");
        token._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(Token storage token, address owner, address spender, uint amount) private {
        uint currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, "TokenComponent: insufficient allowance");
            unchecked {
                _approve(token, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(Token storage token, address from, address to, uint amount) private {}

    function _afterTokenTransfer(Token storage token, address from, address to, uint amount) private {}
}