// SPDX-License-Identifier: BSD-2-Clause
pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/IERC20.sol";

contract Treasury {
    struct Code {
        address main;
    } Code private code;
    address admin;
    mapping(address=>uint256) private balance;

    modifier main() {
        require(msg.sender == main);
    }

    function _deposit_() public main payable {}
    function _withdraw_(address _to, uint256 _value) public main {
        require(_value > 0);
        uint256 _valueWei = _value * 10**18;
        address payable _payable = payable(_to);
        _payable.transfer(_value);
    }

    function _depositERC20_(
        address _contract,
        address _from,
        uint256 _value
    ) public main {
        address _to = address(this);
        IERC20 _token = IERC20(_contract);
        _token.transferFrom(_from, _to, _value);
        balance[_contract] += _value;
    }

    function _withdrawERC20_(
        address _contract,
        address _to,
        uint256 _value
    ) public main {
        address _from = address(this);
        IERC20 _token = IERC20(_contract);
        _token.transfer(_to, _value);
        balance[_contract] -= _value;
    }
}