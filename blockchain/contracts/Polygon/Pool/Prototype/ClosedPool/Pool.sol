pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/Token.sol";

contract Pool {
    struct Funding {
        uint256 start;
        uint256 duration;
        uint256 end;
        uint256 min;
        uint256 max;
        bool onlyWhitelist;
    }

    struct Settings {
        bool creatorCanTransfer;
    }

    address creator;
    
    Settings private settings;
    Funding private funding;
    mapping(address => bool) private whitelisted;

    Token nativeToken;

    modifier wht() {
        require(
            funding.onlyWhitelist &&
            whitelisted[msg.sender],
            "funding.onlyVerified != true || msg.sender != verified"
        );
        _;
    }

    modifier crt() {
        require(
            msg.sender == creator
        );
        _;
    }

    constructor (
        string memory _tknName,
        string memory _tknSymbol,
        uint256 _tknInitialSupply,
        uint256 _fundingDuration,
        uint256 _fundingMin,
        bool _onlyWhitelist,
        bool _creatorCanTransfer
    ) payable {
        uint256 _start = block.timestamp;
        uint256 _end = _start + _fundingDuration;
        address _creator = msg.sender;

        require(msg.value >= 0.01 * 10**18, "Pool: msg.value < 0.01 * 10**18");
        require(_tknInitialSupply >= 1, "Pool: _tknInitialSupply < 1");
        require(_fundingDuration >= 1 weeks, "Pool: _fundingDuration < 1 weeks");
        require(_fundingDuration <= 48 weeks, "Pool: _fundingDuration > 48 weeks");
        require(_fundingMin >= 0, "Pool: _fundingMin < 0");
        require(_creator != address(0), "Pool: _creator == address(0)");

        creator = _creator;
        funding.start = _start;
        funding.end = _end;
        funding.duration = _fundingDuration;
        funding.min = _fundingMin;
        funding.onlyWhitelist = _onlyWhitelist;
        settings.creatorCanTransfer = _creatorCanTransfer;


        /** create token contract & deploy intial supply to creator for their initial contribution */
        nativeToken = new Token(_tknName, _tknSymbol);
        nativeToken.mint(creator, _tknInitialSupply);
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
        return true;
    }

    function withdraw(uint256 _tknValue) public returns (bool) {
        uint256 _supplyWei = nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance;
        uint256 _amountToSend = (_tknValue * _balanceWei) / _supplyWei;

        address payable _withdrawer = payable(msg.sender);
        nativeToken.burn(msg.sender, _tknValue);
        _withdrawer.transfer(_amountToSend);
        return true;
    }

    /** can set white list but will only work if whitelisted only settings is true */
    function setWhitelistOf(address _account, bool _state) public crt returns (bool) {
        whitelisted[_account] = _state;
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
        return true;
    }

    /** recieve matic but will not mint tokens */
    function recieve() public payable crt returns (bool) {
        return true;
    }
}