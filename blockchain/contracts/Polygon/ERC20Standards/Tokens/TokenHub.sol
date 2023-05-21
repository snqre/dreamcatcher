// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "blockchain/contracts/Polygon/ERC20Standards/Tokens/DreamToken.sol";

/** manage dual token model */
contract TokenHub is Initializable, OwnableUpgradeable {

    DreamToken dreamToken;
    EmberToken emberToken;

    /** @custom:oz-upgrades-unsafe-allow constructor */
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        dreamToken = new DreamToken();
        emberToken = new EmberToken();
    }

    /*---------------------------------------------------------------- PRIVATE **/
    function _convertToWei(uint256 value) internal pure returns (uint256) {
        return value * 10**decimals();
    }

    function _mintDreamToken(address to, uint256 amount) internal {
        dreamToken.mint(to, amount);
    }

    function _mintEmberToken(address to, uint256 amount) internal {
        emberToken.mint(to, amount);
    }

    function _burnDreamToken(address account, uint256 amount) internal {
        dreamToken.burn(account, amount);
        /** when dream is burnt is generate ember */
        _randomMintEmber(account, amount);
    }

    /** cannot burn ember */

    uint256 nonce; /** need to find a better way of doing this */
    function _getRandomNumber() internal pure returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce ++;
        return randomNumber;
    }
    
    function _randomMintEmber(address to, uint256 amount) internal {
        /** divide the amount by a random range 0 -> 100 */
        uint256 newAmount = amount / _getRandomNumber();
        emberToken.mint(to, newAmount);
    }

    function _snapshot() internal {
        dreamToken.snapshot();
        emberToken.snapshot();
    }

    /*---------------------------------------------------------------- OWNER COMMANDS **/
    function snapshot() public onlyOwner {
        _snapshot();
    }

    function mintDreamToken(address to, uint256 amount) public onlyOwner {
        _mintDreamToken(to, amount);
    }

    function mintEmberToken(address to, uint256 amount) public onlyOwner {
        _mintEmberToken(to, amount);
    }

    function burnDreamToken(address account, uint256 amount) public onlyOwner {
        /** note every time dream token is burnt an amount of ember is minted to the address */
        _burnDreamToken(account, amount);
    }

    /** cannot burn ember */

    /*---------------------------------------------------------------- PUBLIC **/
    /** show unwavering commitment to dreamcatcher */
    function forge(address account, uint256 amount) public returns (bool) {
        require(amount >= 100000);
        _burnDreamToken(account, amount);
        return true;
    }

}