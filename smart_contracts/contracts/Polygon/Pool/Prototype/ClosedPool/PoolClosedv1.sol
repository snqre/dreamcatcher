// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;











// immutable
contract PoolState is Token {
    mapping(address => uint256) internal contribution;
    address internal manager;
    uint256 internal balance; // wei matic
    struct Funding {
        uint256 start;
        uint256 end;
        uint256 duration;
    }
    Funding internal funding;

    constructor(
        address _admin,
        address _manager,
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        admin = _admin;
        manager = _manager;
        mint(_admin, _initialSupply);
    }

    function setFunding(uint256 _start, uint256 _duration)
        public
        onlyAdmin
        returns (bool)
    {
        funding.start = _start;
        funding.duration = _duration;
        funding.end = _start + _duration;
        return true;
    }

    function fetchFunding()
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (funding.start, funding.end, funding.duration);
    }

    function setBalance(uint256 _amount) public onlyAdmin returns (bool) {
        balance = _amount;
        return true;
    }

    function getBalance() public returns (uint256) {
        return balance;
    }

    function setAdmin(address _account) public onlyAdmin returns (bool) {
        admin = _account;
        return true;
    }

    function getAdmin() public returns (address) {
        return admin;
    }

    function setManager(address _account) public onlyAdmin returns (bool) {
        manager = _account;
        return true;
    }

    function getManager() public returns (address) {
        return manager;
    }

    function setContribution(address _account, uint256 _amount)
        public
        onlyAdmin
        returns (bool)
    {
        require(_amount >= 0, "_amount < 0");
        require(_account != address(0), "_account == address(0)");
        contribution[_account] = _amount;
        return true;
    }

    function contributionOf(address _account) public returns (uint256) {
        return contribution[_account];
    }
}

contract PoolLogic is IERC20 {

}

contract Pool {
    PoolState poolStateContract;
    address immutable state;
    PoolLogic poolLogicContract;
    address logic;

    constructor(
        address _manager,
        string memory _tknName,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        poolStateContract = new PoolState(
            address(this),
            _manager,
            _tknName,
            _symbol,
            _initialSupply
        );
        state = address(poolStateContract);
        poolLogicContract = new PoolLogic();
        logic = address(poolLogicContract);
    }
}

// v1

contract Pool is IERC20 {
    // =.=.= utils
    uint256 infinite = type(uint256).max;
    mapping(string => address) private map;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _maxSupply
    ) {
        require(
            _decimals >= 0 &&
                _decimals <= 18 &&
                _maxSupply >= 1 &&
                _maxSupply <= infinite
        );
        map["QUICKSWAP_ROUTER"] = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

        token.name = _name;
        token.symbol = _symbol;
        token.decimals = _decimals;
        token.totalSupply = 0;
        token.maxSupply = _maxSupply;

        isManager[msg.sender] = true;
        isAdmin[msg.sender] = true;
    }

    function transfer_(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0) &&
                _to != address(0) &&
                balance[_from] >= _value &&
                balance[_from] >= 0 &&
                _value >= 0
        );

        balance[_from] -= _value;
        balance[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function mint_(address _to, uint256 _value) private {
        address _from = address(0);
        require(
            _value >= 0 &&
                _value + token.totalSupply <= token.maxSupply &&
                _to != address(0)
        );

        token.totalSupply += _value;
        balance[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function burn_(address _from, uint256 _value) private {
        address _to = address(0);
        require(_value >= 0 && _value <= balance[_from]);

        token.totalSupply -= _value;
        balance[_from] -= _value;

        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        address _from = msg.sender;
        transfer_(_from, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        address _spender = msg.sender;
        uint256 _allwnc = allowed[_from][_spender];
        require(_allwnc != infinite && _allwnc >= _value);

        allowed[_from][_spender] -= _value;
        transfer_(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        address _owner = msg.sender;
        require(_owner != address(0) && _spender != address(0) && _value >= 0);

        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function name() public view returns (string memory) {
        return token.name;
    }

    function symbol() public view returns (string memory) {
        return token.symbol;
    }

    function decimals() public view returns (uint8) {
        return token.decimals;
    }

    function maxSupply() public view returns (uint256) {
        return token.maxSupply;
    }

    function totalSupply() public view returns (uint256) {
        return token.totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balance[_owner];
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    // =.=.= POOL
    function addToken(IERC20 _token) public manager {
        tokens.push(_token);
    }

    function setPriceAggregator(address _priceAggregator) public manager {
        priceAggregator = AggregatorV3Interface(_priceAggregator);
    }

    function getBalance() public view returns (uint256) {
        uint256 _sumValueInMatic = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 _tokenBalance = tokens[i].balanceOf(address(this));
            uint256 _exchangeRate = getPrice(tokens[i]);

            uint256 _tokenValueInMatic = (_tokenBalance * _exchangeRate) /
                10**18;
            _sumValueInMatic += _tokenValueInMatic;
        }

        return _sumValueInMatic;
    }

    function getPrice(IERC20 _token) public view returns (uint256) {
        address _tokenAddress = address(_token);
        uint256 _tokenDecimals = _token.decimals();

        (, int256 price, , , ) = priceAggregator.latestRoundData();

        uint256 _exchangeRate = uint256(price) * 10**(18 - _tokenDecimals);

        return _exchangeRate;
    }

    function contribute() public payable returns (bool) {
        address _buyers = msg.sender;
        address _seller = address(this);
        uint256 _value = msg.value;
        uint256 _balance = getBalance();
        uint256 _supply = token.totalSupply;
        require(_value > 0 && _balance > 0 && _supply > 0);
        uint256 _amountOfTokensToMint = (_value * _supply) / _balance;
        mint_(_buyers, _amountOfTokensToMint);
        return true;
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 _amoutnIn,
        uint256 _amountOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) public manager returns (bool) {
        address _contract = map["QUICKSWAP_ROUTER"];
        IUniswapV2Router02(_contract)
            .swapExactTokensForTokensSupportingFeeOnTrasferTokens(
                _amountIn,
                _amountOutMin,
                _path,
                _to,
                _deadline
            );
        return true;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 _amountOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) public payable manager returns (bool) {
        address _contract = map["QUICKSWAP_ROUTER"];
        IUniswapV2Router02(_contract)
            .swapExactETHForTokensSupportingFeeOnTransferTokens(
                _amountOutMin,
                _path,
                _to,
                _deadline
            );
        return true;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] calldata _path,
        address _to,
        uint256 _deadline
    ) public manager returns (bool) {
        address _contract = map["QUICKSWAP_ROUTER"];
        IUniswapV2Router02(_contract)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                _amountIn,
                _amountOutMin,
                _path,
                _to,
                _deadline
            );
        return true;
    }
}
