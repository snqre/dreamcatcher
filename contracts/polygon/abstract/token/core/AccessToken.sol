// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC20/ERC20.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Snapshot.sol";
import "contracts/polygon/external/openzeppelin/token/ERC20/extensions/ERC20Permit.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/abstract/utils/core/Timer.sol";

abstract contract AccessToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Ownable, Timer {

    /**
    * @dev Private variable to store the maximum supply.
    */
    uint256 private _maxSupply;

    /**
    * @dev Private variable to track whether transfers are allowed.
    */
    bool private _transferable;

    /**
    * @dev Private variable to track whether burning is allowed.
    */
    bool private _burnable;

    /**
    * @dev Private variable to track whether minting is allowed.
    */
    bool private _mintable;

    /**
    * @dev Private variable to track whether the contract is timed.
    */
    bool private _timed;

    /**
    * @dev Private variable to track whether the contract should reset on completion.
    */
    bool private _resetOnCompletion;

    constructor(string memory name, string memory symbol) 
        ERC20(name, symbol) 
        ERC20Permit(name) 
        Ownable(msg.sender) {
        _maxSupply = _single();
        _transferable = false;
        _burnable = false;
        _mintable = false;
        _timed = false;
        _resetOnCompletion = false;
    }

    /** Access */

    function access(address account) public view virtual {
        require(balanceOf(account) >= _single(), "AccessToken: unauthorized");
        if (timed()) {
            require(hasStarted(), "AccessToken: premature");
            require(!hasEnded(), "AccessToken: expired");
        }
    }

    /** maxSupply */

    function maxSupply() public view virtual returns (uint256) {
        /**
        * @dev Sets a limit to the amount of access tokens that can
        *      be minted.
         */
        return _maxSupply;
    }

    function setMaxSupply(uint256 amount) public virtual onlyOwner() {
        _maxSupply = _convertToWei(amount);
    }

    /** transferable */

    function transferable() public view virtual returns (bool) {
        /**
        * @dev Allows anyone to transfer their access token to another account.
         */
        return _transferable;
    }

    function transfer(address to, uint256 amount) public virtual override {
        require(transferable(), "AccessToken: !transferable()");
        super.tranfer(to, _convertToWei(amount));
    }

    function transferFrom(address from, address to, uint256 amount) public virtual onlyOwner() {
        _transfer(from, to, _convertToWei(amount));
    }

    function setTransferable(bool boolean) public virtual onlyOwner() {
        _transferable = boolean;
    }

    /** Burnable */

    function burnable() public view virtual returns (bool) {
        /**
        * @dev Allows anyone carrying the access token to burn their supply of tokens
        *      and remove their access.
         */
        return _burnable;
    }

    function burn(uint256 amount) public virtual {
        require(burnable(), "AccessToken: !burnable()");
        _burn(msg.sender, _convertToWei(amount));
    }

    function burnFrom(address account, uint256 amount) public virtual onlyOwner() {
        _burn(account, _convertToWei(amount));
    }

    function setBurnable(bool boolean) public virtual onlyOwner() {
        _burnable = boolean;
    }

    /** Mintable */

    function mintable() public view virtual returns (bool) {
        /**
        * @dev Allows anyone carrying at least one access token to mint one more
        *      ideal for smart contracts which carry out a designated function
        *      NOT ideal in the hands of people.
         */
        return _mintable;
    }

    function mint(uint256 amount) public virtual {
        require(mintable(), "AccessToken: !mintable()");
        require(balanceOf(msg.sender) >= _convertToWei(1), "AccessToken: must have at least 1 token");
        _mint(msg.sender, _convertToWei(amount));
    }

    function mintTo(address account, uint256 amount) public virtual onlyOwner() {
        _mint(account, amount);
    }

    function setMintable(bool boolean) public virtual onlyOwner() {
        _mintable = boolean;
    }

    /** Timed */

    function timed() public view virtual returns (bool) {
        /**
        * @dev Allows setting a timer for the role, once the timer
        *      is completed the access function will revert making
        *      the role unusable. It can be reset by the owner
        *      again.
         */
        return _timed;
    }

    function setStartTimestamp(uint256 timestamp) public virtual onlyOwner() {
        _setStartTimestamp(timestamp);
    }

    function increaseStartTimestamp(uint256 seconds_) public virtual onlyOwner() {
        _increaseStartTimestamp(seconds_);
    }

    function decreaseStartTimestamp(uint256 seconds_) public virtual onlyOwner() {
        _decreaseStartTimestamp(seconds_);
    }

    function setDuration(uint256 seconds_) public virtual onlyOwner() {
        _setDuration(seconds_);
    }

    function _increaseDuration(uint256 seconds_) public virtual onlyOwner() {
        _increaseDuration(seconds_);
    }

    function _decreaseDuration(uint256 seconds_) public virtual onlyOwner() {
        _decreaseDuration(seconds_);
    }

    /** Voting */

    function getCurrentSnapshotId() public view virtual returns (uint256) {
        return _getCurrentSnapshotId();
    }

    function snapshot() public returns (uint256) {
        _snapshot();
        return _getCurrentSnapshotId();
    }

    /** */

    function _single() internal pure virtual returns (uint256) {
        return _convertToWei(1);
    }

    function _convertToWei(uint256 value) internal pure virtual returns (uint256) {
        return value * (10**decimals());
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Snapshot) {
        require(balanceOf(to) == 0, "ERC20FullOwnableRole: only one per account");
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        require(totalSupply() <= maxSupply(), "ERC20FullOwnableRole: too many assigned");
        super._afterTokenTransfer(from, to, amount);
    }
}