// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title MonkeyNFT
 * @dev A contract for an NFT collection with public and whitelist minting functions, withdrawal of funds, and implementation of ERC721 and ERC721Enumerable interfaces.
 */
contract MonkeyNFT is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;

    // Maximum supply of NFTs
    uint256 public MAX_SUPPLY = 2000;

    // Price to mint NFT for public
    uint256 public PUBLIC_MINT_PRICE = 0.01 ether;

    // Price to mint NFT for whitelist
    uint256 public WHITELIST_MINT_PRICE = 0.001 ether;

    // Maximum number of addresses that can be added to whitelist
    uint256 public MAX_WHITELIST_ADDRESS = 300;

    // Total number of addresses added to whitelist
    uint256 public TOTAL_WHITELIST_ADDRESS;

    // Mapping of address to number of NFTs minted
    mapping(address => uint256) public mintedWallet;

    // Mapping of address to whitelist status
    mapping(address => bool) public whiteListAddress;

    constructor() ERC721("Monkey", "MKT") {}

    /**
     * @dev Returns the base URI for the NFT collection.
     */
    function _baseURI() internal pure override returns (string memory) {
        return
            "https://ipfs.io/ipfs/QmQ2wN5W8x62H3Gmm9Pp5kWsZN5hf5RKLb5zAQ1JtDwKt8/";
    }

    /**
     * @dev Pauses all token transfers.
     * Only the owner can call this function.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     * Only the owner can call this function.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Adds the caller's address to the whitelist.
     * Only if the whitelist limit has not been reached.
     */
    function getWhiteList() external {
        require(
            TOTAL_WHITELIST_ADDRESS < MAX_WHITELIST_ADDRESS,
            "Maximum whitelist limit reached"
        );
        TOTAL_WHITELIST_ADDRESS++;
        whiteListAddress[msg.sender] = true;
    }

    /**

@dev Mints NFTs for the public. Only if the total supply is less than the maximum supply. The caller must pay the required amount.
@param _quantity The number of NFTs to mint.
*/

    function publicMint(uint256 _quantity) external payable {
        require(
            totalSupply().add(_quantity) <= MAX_SUPPLY,
            "NFT collection sold out!"
        );
        require(
            msg.value == PUBLIC_MINT_PRICE.mul(_quantity),
            "Please pay the required amount"
        );

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            mintedWallet[msg.sender]++;
            _safeMint(msg.sender, tokenId);
        }
    }


    /**

@dev Mints NFTs for whitelisted addresses. Only if the total supply is less than the maximum supply. The caller must pay the required amount.
@param _quantity The number of NFTs to mint.
*/

    function whiteListMint(uint256 _quantity) external payable {
        require(
            totalSupply().add(_quantity) <= MAX_SUPPLY,
            "NFT collection sold out!"
        );
        require(
            msg.value == WHITELIST_MINT_PRICE.mul(_quantity),
            "Please pay the required amount"
        );

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            mintedWallet[msg.sender]++;
            _safeMint(msg.sender, tokenId);
        }
    }

    /**
@dev Withdraws contract funds to the specified address. Only callable by the contract owner.
@param _to The address to withdraw the funds to.
*/

    function withDrawFunds(address _to) external onlyOwner {
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Funds transfer failed");
    }


    /**

@dev This function is called internally by the ERC721 and ERC721Enumerable contracts before a token is transferred. It checks if the contract is not paused and invokes the parent's _beforeTokenTransfer function.
@param _from The address of the sender.
@param _to The address of the recipient.
@param _tokenId The ID of the token being transferred.
@param _batchSize The size of the batch of tokens being transferred.
*/

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(_from, _to, _tokenId, _batchSize);
    }


    /**
@dev Checks if the contract supports the specified interface.
@param interfaceId The interface ID to check.
@return A boolean indicating whether the interface is supported or not.
*/

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
