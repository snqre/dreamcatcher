// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Token is IERC20, ERC20 {
    address private owner;

    modifier only_owner() {
        require(msg.sender ==owner);
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(
        _name,
        _symbol
    ) {
        owner =msg.sender;
    }

    function mint(
        address _to,
        uint256 _tokens_to_mint

    ) public only_owner returns (bool) {
        require(_to !=address(0));
        require(_tokens_to_mint >=0);

        super._mint(
            _to,
            _tokens_to_mint *10 **18
        );

        return true;
    }

    function burn(
        address _from,
        uint256 _tokens_to_burn

    ) public only_owner returns (bool) {
        require(_from !=address(0));
        require(_tokens_to_burn >=0);
        
        super._burn(
            _from,
            _tokens_to_burn *10 **18
        );

        return true;
    }
}