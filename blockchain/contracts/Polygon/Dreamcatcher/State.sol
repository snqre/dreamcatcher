pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/IERC20.sol";
contract State {
    struct Machine {
        
    } Machine private machine;

    address logic;
    mapping(string => mapping(address => bool)) private role;
    mapping(address => bool) private isBoard;

    event Deposit(address _from, uint256 _value);
    event Withdrawal(address _to, uint256 _value);
    event DepositERC20();
    event WithdrawalERC20();
    
    modifier onlyLogic() {
        require(msg.sender == logic, "State >. msg.sender is not assigned logic contract");
        _;
    }

    constructor(
    ) {
        /** tell it where to find logic code required */
        logic = msg.sender;

        role["Board"][msg.sender] = true;
    }

    function setRole(
        string memory _role,
        address _of,
        bool _is
    ) public {
        
    }

    function setBoardOf(address _account, bool _state) public {
        
    }

    function withdraw(address _to, uint256 _value) public onlyLogic returns (bool) {
        address _from = address(this);
        address payable _recipient = payable(_to);
        uint256 _valueWei = _value * 10**18;
        _recipient.transfer(_valueWei);
        emit Withdrawal(_to, _value);
        return true;
    }

    /** only token contract */
    function getBalanceOf(address _contract) public view returns (uint256) {
        IERC20 _token = IERC20(_contract);
        return _token.balanceOf(address(this));
    }

}