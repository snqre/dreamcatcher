pragma solidity ^0.8.0;
import "blockchain/contracts/Polygon/ERC20Standards/Token.sol";

/**
* Every pool has an initial funding round
* They can choose if they want it to be public or for only whitelisted addresses
* Anyone can withdraw even if they are no longer whitelisted
* Creators can choose to allow themselves to transfer value out of the pool this comes with some risk and external checks and due diligence must be made
* The contract must be deployed with some matic
* The first initial supply will be mineted to the creator for that contribution, setting the bassline net asset value per token
* The creator can set a required amount of matic for the pool to be successful, if it isnt passed, contributors can withdraw their contributions
* Contributors can withdraw their contributions regardless at any time before the funding round is complete and passed
* Some settings are immutable and others can be changed
* Changed settings will only start working after the time delay
* We try to leave room for regulatory compliance
* The creator can be another smart contract which operates in a decentralized manner
* A locked fund can only take in matic contributions at the start
* Any funding rounds will be for a set price
* We are unable to have further funding rounds after because we cant calculate balance onchain after matic has been swapped for other assets
* Creators can designate matic to be distributed to contributors based on the % of ownership of the pool
* Pools with a distribution date will forcefully approve withdrawals of the underlying assets if the creator does not distribute the pool in matic
* Built in swaps are designated to our Market code, are can be called through string to interact with our other contracts
* Again external contracts can be added but risk warnings will be put up, ideally these are run by KYC verified institutions or investors and require legal backing
 */

contract Pool {
    struct My {
        Token nativeToken;
        string name;
        string description;
        address creator;
    } My private my;

    
    bool fundingRoundIsSetUp;
    /**
    * duration: amount the funding round will go on for in seconds
    * start: when the initial funding round is starting
    * end: when does the initial funding round end
    * required: what is the minimum required for this pool to successfully run 
    * isWhitelisted: only whitelisted accounts can contribute and participate to initial funding round
    * isTransferable: the creator of the pool can transfer value out of the pool
     */
    struct Funding {
        uint256 duration;
        uint256 start;
        uint256 end;
        uint256 required;
        bool isWhitelisted;
        bool isTransferable;
    } Funding private funding;

    /**
    * hasGovernance: members of this pool can propose to do swap or do something with the value in the vault
    *
    *
     */

    struct Settings {
        bool hasGovernance;
    } Settings private settings;

    struct Proposal {
        uint256 id;
        address proposer;
        string caption;
        string description;
        uint256 yes;
        uint256 no;
        uint256 abstain;
        bool passed;
        bool executed;
    } mapping(uint256 => Proposal) private proposals;
    
    mapping(address => bool) private whitelistOf;

    event FundingRoundSetUp(
        uint256 _duration,
        uint256 _start,
        uint256 _end,
        uint256 _required,
        bool _whitelisted,
        bool _transferable
    );

    event Contribution(address indexed _from, uint256 _value, uint256 _mint);
    event Withdrawal(address indexed _from, uint256 _burn, uint256 _value);

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

    modifier onlyWhitelisted() {
        require(funding.isWhitelisted == true);
        require(whitelistOf[msg.sender] == true);
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == meta.creator);
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

        meta.creator = _creator;

        /** create token contract & deploy intial supply to creator for their initial contribution */
        meta.nativeToken = new Token(_tokenName, _tokenSymbol);
        meta.nativeToken.mint(_creator, _tokenInitialSupply);

        emit PoolFounded(
            _creator,
            _name,
            _tokenName,
            _tokenSymbol,
            _tokenInitialSupply
        );
    }
    
    function contribute() onlyWhitelisted public payable returns (bool) {
        uint256 _valueWei = msg.value;
        uint256 _supplyWei = meta.nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance - _valueWei;
        uint256 _amountToMint = (_valueWei * _supplyWei) / _balanceWei;

        require(_valueWei > 0);
        require(_supplyWei > 0);
        require(_balanceWei > 0);

        meta.nativeToken.mint(msg.sender, _amountToMint);
        emit Contribution(
            msg.sender,
            _valueWei * 10**18,
            _amountToMint
        );
        return true;
    }

    function withdraw(uint256 _tknValue) public returns (bool) {
        uint256 _supplyWei = meta.nativeToken.totalSupply() / 10**18;
        uint256 _balanceWei = address(this).balance;
        uint256 _amountToSend = (_tknValue * _balanceWei) / _supplyWei;

        address payable _withdrawer = payable(msg.sender);
        meta.nativeToken.burn(msg.sender, _tknValue);
        _withdrawer.transfer(_amountToSend);
        emit Withdrawal(
            _withdrawer,
            _tknValue,
            _amountToSend
        );
        return true;
    }

    /** can set white list but will only work if whitelisted only settings is true */
    function setWhitelistOf(address _account, bool _state) public onlyCreator returns (bool) {
        whitelistOf[_account] = _state;
        emit WhitelistUpdated(_account, _state);
        return true;
    }

    function whitelist(address _account) public view returns (bool) {
        return whitelistOf[_account];
    }

    function transfer(address _account, uint256 _value) public onlyCreator returns (bool) {
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
    function recieve() public payable onlyCreator returns (bool) {
        emit TransferIn(msg.value);
        return true;
    }

    /** can only be done once */
    function setUpFundingRound(
        /** duration of funding round */
        uint256 _duration,
        /** required amount of value for the pool to continue */
        uint256 _required,
        /** only whitelisted accounts can contribute to the pool */
        bool _whitelisted,
        /** the creator can transfer value out of the contract */
        bool _transferable
    ) public onlyCreator returns (bool) {
        require(fundingRoundIsSetUp == false, "Pool: initial funding round has already been set up");
        require(_duration >= 1 weeks, "Pool: duration of funding round is insufficient");
        require(_required >= 0, "Pool: required value from funding round is less than 0");
        uint256 _start = block.timestamp;
        uint256 _end = _start + _duration;
        funding.duration = _duration;
        funding.start = _start;
        funding.end = funding.start + _duration;
        funding.required = _required;
        funding.whitelisted = _whitelisted;
        funding.transferable = _transferable;
        emit FundingRoundSetUp(
            _duration,
            _start,
            _end,
            _required,
            _whitelisted,
            _transferable
        );
        fundingRoundIsSetUp = true;
        return true;
    }

    /** our pools can interact directly with us and our extensions */
    function interactWithDreamcatcher(string memory _commands) public onlyCreator returns (bool) {
        /** interfact with dreamcatcher */
        /** in dreamcatcher will read the commands and then perform a swap, the contract will approve any transfers */
        /** our contracts are guarded by our DAO community and changes to them will only take effect after the period of timelock */
    }

    function vote(uint256 _id, bool _support) public {
        
    }
}