// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/external/openzeppelin/token/ERC721/ERC721.sol";
import "contracts/polygon/external/openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "contracts/polygon/external/openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import "contracts/polygon/external/openzeppelin/token/ERC721/extensions/ERC721Pausable.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";
import "contracts/polygon/external/openzeppelin/token/ERC721/extensions/ERC721Burnable.sol";
import "contracts/polygon/external/openzeppelin/utils/cryptography/EIP712.sol";
import "contracts/polygon/external/openzeppelin/token/ERC721/extensions/ERC721Votes.sol";

abstract contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, ERC721Burnable, EIP712, ERC721Votes {
    uint256 private _nextTokenId;

    constructor(string memory name, string memory symbol, address initialOwner)
        ERC721(name, symbol)
        Ownable(initialOwner)
        EIP712(name, "1") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function setTokenURI(uint256 tokenId, string memory uri) public onlyOwner() {
        _setTokenURI(tokenId, uri);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Enumerable, ERC721Pausable, ERC721Votes) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable, ERC721Votes) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}