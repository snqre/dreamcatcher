pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/Token.sol";

contract Pool {
    bool fundingRoundIsSetUp;
    uint256 durationOfFundingRound;
    uint256 startOfFundingRound;
    uint256 endOfFundingRound;
    uint256 requiredFromFundingRound;
    bool onlyWhitelistedAccountsCanContribute;
    bool creatorCanTransferOutOfContract;

    string name;

    address creator;
    
    mapping(address => bool) private whitelisted;

    Token nativeToken;

    event FundingRoundSetUp(
        uint256 _durationOfFundingRound,
        uint256 _startOfFundingRound,
        uint256 _endOfFundingRound,
        uint256 _requiredFromFundingRound,
        bool _onlyWhitelistedAccountsCanContribute,
        bool _creatorCanTransferOutOfContract
    );

    event Contribution(
        address indexed _contributor,
        uint256 _valueRecieved,
        uint256 _amountMintedToContributor
    );

    event Withdrawal(
        address indexed _withdrawer,
        uint256 _amountBurntFromWithdrawer,
        uint256 _valueSent
    );

    event WhitelistUpdated(address indexed _account, bool _newState);

    event TransferOut(address indexed _account, uint256 _value);
    event TransferIn(uint256 _value);

    event PoolFounded(
        address indexed _creator,
        string _name,
        string _tokenName,
        string _tokenSymbol,
        uint256 _tokenInitialSupply
    );

    modifier wht() {
        require(onlyWhitelistedAccountsCanContribute, "Pool: onlyWhitelistedAccountsCanContribute setting must be enabled");
        require(whitelisted[msg.sender], "Pool: msg.sender is not whitelisted");
        _;
    }

    modifier crt() {
        require(msg.sender == creator, "Pool: msg.sender is not then contract creator");
        _;
    }

    constructor (
        string memory _name,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenInitialSupply
    ) payable {
        address _creator = msg.sender;

        require(msg.value >= 0.01 * 10**18, "Pool: msg.value insufficient");
        require(_tokenInitialSupply >= 1, "Pool: _tokenInitialSupply insufficient");
        require(_creator != address(0), "Pool: _creator is zero address");

        creator = _creator;

        /** create token contract & deploy intial supply to creator for their initial contribution */
        nativeToken = new Token(_tokenName, _tokenSymbol);
        nativeToken.mint(_creator, _tokenInitialSupply);

        emit PoolFounded(
            _creator,
            _name,
            _tokenName,
            _tokenSymbol,
            _tokenInitialSupply
        );
    }
    
    // ** are we adding value before checking balance?
    function contribute() wht public payable returns (bool) {
        uint256 _valueWei = msg.value;
        uint256 _supplyWei = nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance - _valueWei;
        uint256 _amountToMint = (_valueWei * _supplyWei) / _balanceWei;

        require(
            _valueWei > 0 * 10**18 &&
            _supplyWei > 0 * 10**18 &&
            _balanceWei > 0 * 10**18
        );

        nativeToken.mint(msg.sender, _amountToMint);
        emit Contribution(
            msg.sender,
            _valueWei * 10**18,
            _amountToMint
        );
        return true;
    }

    function withdraw(uint256 _tknValue) public returns (bool) {
        uint256 _supplyWei = nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance;
        uint256 _amountToSend = (_tknValue * _balanceWei) / _supplyWei;

        address payable _withdrawer = payable(msg.sender);
        nativeToken.burn(msg.sender, _tknValue);
        _withdrawer.transfer(_amountToSend);
        emit Withdrawal(
            _withdrawer,
            _tknValue,
            _amountToSend
        );
        return true;
    }

    /** can set white list but will only work if whitelisted only settings is true */
    function setWhitelistOf(address _account, bool _state) public crt returns (bool) {
        whitelisted[_account] = _state;
        emit WhitelistUpdated(_account, _state);
        return true;
    }

    function whitelistOf(address _account) public view returns (bool) {
        return whitelisted[_account];
    }

    function transfer(address _account, uint256 _value) public crt returns (bool) {
        address payable _recipient = payable(_account);
        require(
            settings.creatorCanTransfer &&
            _recipient != address(0) &&
            _value >= 0
        );

        _recipient.transfer(_value);
        emit TransferOut(_account, _value);
        return true;
    }

    /** recieve matic but will not mint tokens */
    function recieve() public payable crt returns (bool) {
        emit TransferIn(_value);
        return true;
    }

    function setUpFundingRound(
        uint256 _durationOfFundingRound,
        uint256 _requiredFromFundingRound,
        bool _onlyWhitelistedAccountsCanContribute,
        bool _creatorCanTransferOutOfContract
    ) public crt returns (bool) {
        durationOfFundingRound = _durationOfFundingRound;
        startOfFundingRound = block.timestamp;
        endOfFundingRound = startOfFundingRound + durationOfFundingRound;
        requiredFromFundingRound = _requiredFromFundingRound;
        onlyWhitelistedAccountsCanContribute = _onlyWhitelistedAccountsCanContribute;
        creatorCanTransferOutOfContract = _creatorCanTransferOutOfContract;
        emit FundingRoundSetUp(
            _durationOfFundingRound,
            _startOfFundingRound,
            _endOfFundingRound,
            _requiredFromFundingRound,
            _onlyWhitelistedAccountsCanContribute,
            _creatorCanTransferOutOfContract
        );
        fundingRoundIsSetUp = true;
        return true;
    }
}