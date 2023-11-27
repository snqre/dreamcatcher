// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// sepcial case ! im not separting the private and internal (event) functions here
/// maybe in a future version
library TokenComponent {
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

    function transfer(Token storage token, address to, uint amount) internal returns (bool) {
        address owner = msg.sender;
        _transfer(token, owner, to, amount);
        return true;
    }

    function mint(Token storage token, address account, uint amount) internal returns (bool) {
        _mint(token, account, amount);
        return true;
    }

    function burn(Token storage token, uint amount) internal returns (bool) {
        address owner = msg.sender;
        _burn(token, owner, amount);
        return true;
    }

    function burnFrom(Token storage token, address account, uint amount) internal returns (bool) {
        _spendAllowance(token, account, msg.sender, amount);
        _burn(account, amount);
        return true;
    }

    function approve(Token storage token, address spender, uint amount) internal returns (bool) {
        address owner = msg.sender;
        _approve(token, owner, spender, amount);
        return true;
    }

    function transferFrom(Token storage token, address from, address to, uint amount) internal returns (bool) {
        address spender = msg.sender;
        _spendAllowance(token, from, spender, amount);
        _transfer(token, from, to, amount);
        return true;
    }

    function increaseAllowance(Token storage token, address spender, uint addedValue) internal returns (bool) {
        address owner = msg.sender;
        _approve(token, owner, spender, allowance(token, owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(Token storage token, address spender, uint subtractedValue) internal returns (bool) {
        address owner = msg.sender;
        uint currentAllowance = allowance(token, owner, spender);
        require(currentAllowance >= subtractedValue, "TokenComponent: decreased allowance below zero");
        unchecked {
            _approve(token, owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(Token storage token, address from, address to, uint amount) private returns (bool) {
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
        return true;
    }

    function _mint(Token storage token, address account, uint amount) private returns (bool) {
        require(account != address(0), "TokenComponent: mint to the zero address");
        _beforeTokenTransfer(token, address(0), account, amount);
        token._totalSupply += amount;
        unchecked {
            token._balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(token, address(0), account, amount);
        return true;
    }

    function _burn(Token storage token, address account, uint amount) private returns (bool) {
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
        return true;
    }

    function _approve(Token storage token, address spender, uint amount) private returns (bool) {
        require(owner != address(0), "TokenComponent: approve from the zero address");
        require(spender != address(0), "TokenComponent: approve to the zero address");
        token._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function _spendAllowance(Token storage token, address owner, address spender, uint amount) private returns (bool) {
        uint currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, "TokenComponent: insufficient allowance");
            unchecked {
                _approve(token, spender, currentAllowance - amount);
            }
        }
        return true;
    }

    function _beforeTokenTransfer(Token storage token, address from, address to, uint amount) private returns (bool) {
        return true;
    }

    function _afterTokenTransfer(Token storage token, address from, address to, uint amount) private returns (bool) {
        return true;
    }
}