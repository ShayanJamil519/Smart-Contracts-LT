// SPDX-License-Identifier: GPL-3.0
pragma solidity  ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract RealStatePropertyTokenizationContract is ERC20 {

    // string public name = "Real Estate Token";
    // string public symbol = "RET";
    // uint8 public decimals = 18;

    constructor(string memory name, string memory symbol) ERC20(name, symbol){}
    
    // Token Structure
    struct Token{
        address owner;
        uint256 tokenId;
        string propertyAddress;
        uint256 totalSupply;
        uint256 availableSupply;
    }

    // mapping
    mapping (uint256=> Token) public tokens;

    uint256 public nextTokenId = 0;

    // Function For Tokenizing a Property
    function tokenizeProperty(string memory _propertyAddress, uint256 _totalSupply, address ownerOfProperty) public{

        require(msg.sender == ownerOfProperty, "Only Property Owner Can Tokenize A Property");

        // Creating a new token and adding it to the mapping
        Token memory newToken = Token({
            owner:msg.sender,
            tokenId:nextTokenId,
            propertyAddress:_propertyAddress,
            totalSupply:_totalSupply,
            availableSupply:_totalSupply
        });

        tokens[nextTokenId] = newToken;
        nextTokenId++;

    }


    // Function For buying Tokens
    function buyTokens(uint256 _tokenId, uint256 _quantity) public payable{
        // Ensuring that tokens exists
        require (_tokenId < nextTokenId, "Token Doesn't Exist");

      // Get the token from the mapping
        Token storage token = tokens[_tokenId];

        // Ensuring that there are enough tokens avaialble for purchase
        require(token.totalSupply >= _quantity, "Not enough tokens available for purchase");

        // Calculating the price for tokens
        uint256 price = token.totalSupply / token.availableSupply;
        uint256 totalPrice = price * _quantity;

        // Ensuring that the buyer has sent enough ether to purchase the tokens
        require(msg.value >= totalPrice, "Not Enough Ether sent to purchase tokens");

        // Transfer the tokens to the buyer
        transfer(msg.sender, _quantity);

        // Send the Ether to the token owner
        payable(token.owner).transfer(totalPrice);
    }

}
