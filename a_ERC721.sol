// SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;


//  ***** Requirements ***** 
// - Ethereum ERC-721
// - No cap supply
// - Mint cost covered by admin
// - Non-tradeable
// - Tradeable by admin only
// - Not mintable by the public



// Imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// Errors
error AdminTransferrable__RoleNotGranted();


contract AdminTransferrable is ERC721, Ownable{

    // State Variables
    uint256 public _tokenIdCounter;
    string private currentBaseURI;

    // random address where tokens transfer by the user
    address public vault;

    // Events
    event NftTransferRequest(address indexed from, address indexed to, uint256 tokenId);

    // Mappings
    mapping (address=> bool) public isOwnerShip;

    // Modifier
    modifier onlyAdmin(){
        if(isOwnerShip[msg.sender] != true){
            revert AdminTransferrable__RoleNotGranted();
        }
        _;
    }

    constructor() ERC721("NOTTRADEABLE", "NTNFT"){
        isOwnerShip[msg.sender] = true;
        vault = msg.sender;
    }

    // Overriding Base Contract functions so that onlyAdmin can call that function
    // Safely Transfers nft from one user address to another
    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAdmin{
        super.safeTransferFrom(from, to, tokenId);
    }
    // Safely Transfers nft from one user address to another contract address
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override onlyAdmin{
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAdmin{
        super.transferFrom(from, to, tokenId);
    }

    // user requests for transferring nfts
    function nftTransferRequest(address to, uint256 tokenId) public {
        super.safeTransferFrom(msg.sender, vault, tokenId);  // user have to first transfers nft to admin
        emit NftTransferRequest(msg.sender, to, tokenId);   // then user can transfer to 'to' address
    }

    // Admin -> minting
    function mint(address to) public onlyAdmin{
        _safeMint(to, _tokenIdCounter);
        _tokenIdCounter += 1;
    }
    

    // Changes Vault(admin) address
    function changeVaultAddress(address newVaultAddress) public onlyOwner{
        vault = newVaultAddress;
    }

    // Granting role to another user as admin by current admin
    function grantRole(address to) public onlyAdmin{
        isOwnerShip[to] = true;
    }
    

    function setBaseURI(string memory _newBaseURI) public onlyOwner{
        currentBaseURI = _newBaseURI;
    }

    // Getter Functions

    function _baseURI() internal view virtual override returns(string memory){
        return currentBaseURI;
    }

     // Checks if user is a admin?
    function Owners(address to) public view returns(bool){
        return isOwnerShip[to];
    }


    // Returns the owner of nft
    function checkOwnership(uint256 tokenId) public view returns (address){
        return ownerOf(tokenId);
    }

    // returns current token id
    function getCurrentTokenId() public view returns (uint256){
        return _tokenIdCounter;
    }


}
