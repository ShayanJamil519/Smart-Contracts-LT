WhiteListing and Public NFTs  minting


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extension/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MonkeyNFT {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public MAX_SUPPLY=2000;
    uint256 public PUBLIC_MINT_PRICE= 0.01 ether;
    uint256 public WHITELIST_MINT_PRICE= 0.001 ether;
    uint256 public MAX_WHITELIST_ADDRESS=300;
    uint256 public TOTAL_WHITELIST_ADDRESS;



    mapping(address=>uint256) public mintedWallet;
    mapping(address=>bool) public whiteListAddress;


    constructor() ERC721("Monkey", "MKT"){

    }

    function _baseURI() internal pure override returns (string memory){
        return "https://ipfs.io/ipfs/QmQ2wN5W8x62H3Gmm9Pp5kWsZN5hf5RKLb5zAQ1JtDwKt8/";
    }

    function pause() public onlyOwner{
        _pause();
    }

    function unpause() public onlyOwner{
        _unpause();
    }

    function getWhiteList() public{
        require(TOTAL_WHITELIST_ADDRESS < MAX_WHITELIST_ADDRESS, "Maximum whitelist limit reached");
        TOTAL_WHITELIST_ADDRESS++;
        whiteListAddress[msg.sender] = true;
    }

    function publicMint(uint256 _quantity) public payable{
        require(totalSupply() + _quantity <= MAX_SUPPLY, "NFT collection sold out!");
        require(msg.value == PUBLIC_MINT_PRICE * _quantity, "Please pay the required amount");

        for (uint256 i =0; i<_quantity; i++){
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            mintedWallet[msg.sender]++;
            _safeMint(msg.sender, tokenId);
        }
    }

      function whiteListMint(uint256 _quantity) public payable{
        require(totalSupply() + _quantity <= MAX_SUPPLY, "NFT collection sold out!");
        require(msg.value == WHITELIST_MINT_PRICE * _quantity, "Please pay the required amount");

        for (uint256 i =0; i<_quantity; i++){
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            mintedWallet[msg.sender]++;
            _safeMint(msg.sender, tokenId);
        }
    }

    function withDrawFunds(address _to) public onlyOwner{
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Funds transfer failed");

    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId, uint256 _batchSize) internal override(ERC721, ERC721Enumerable) whenNotPaused{
        super._beforeTokenTransfer(_from, _to, _tokenId, _batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }

}
