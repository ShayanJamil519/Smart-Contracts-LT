Characterization

Client side interface:
The client-side interface will simply display a link to a specific article page that the journalist has created. The link will be shareable with others and can be accessed by anyone who has the link.
Article Payment: When a user clicks on the link, they will be directed to an article page that displays the article title and hash content. The page will also include a "pay to view" button that users need to click to access the content. After the payment is processed, the content will be displayed on the same page.
Journalist side interface:
A journalist-side interface will allow journalists to register articles by providing the article title, author name and content hash of the article. The dashboard will also allow journalists to view their listed articles and track the number of views and payments received.
Registering an article: When a journalist clicks the "Register an article" button, he will be redirected to a page where he can enter the title of the article, the name of the author and the hash of the content. The page will also include a function that generates a unique link that can be shared with others to distribute the article.


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ArticleSharingPlatform {
    
    struct Article {
        string title;
        string authorName;
        string contentHash;
        uint views;
        uint earnings;
    }
    
    mapping(string => Article) public articles;
    mapping(address => mapping(string => bool)) public userAccess;
    
    address payable public owner;
    uint public articlePrice;
    
    event ArticleRegistered(string title, string authorName, string contentHash, string articleLink);
    event ArticleViewed(string title, string authorName, address user, uint earnings);
    
    constructor(uint _articlePrice) {
        owner = payable(msg.sender);
        articlePrice = _articlePrice;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action.");
        _;
    }
    
    function registerArticle(string memory _title, string memory _authorName, string memory _contentHash) public onlyOwner {
        string memory articleLink = generateArticleLink(_title, _authorName);
        articles[articleLink] = Article(_title, _authorName, _contentHash, 0, 0);
        emit ArticleRegistered(_title, _authorName, _contentHash, articleLink);
    }
    
    function generateArticleLink(string memory _title, string memory _authorName) private pure returns (string memory) {
        return string(abi.encodePacked(_title, "-", _authorName));
    }
    
    function viewArticle(string memory _title, string memory _authorName) public payable {
        string memory articleLink = generateArticleLink(_title, _authorName);
        require(articles[articleLink].views >= 0, "Article does not exist.");
        require(msg.value == articlePrice, "Incorrect payment amount.");
        require(userAccess[msg.sender][articleLink] == false, "User already has access.");
        
        userAccess[msg.sender][articleLink] = true;
        articles[articleLink].views += 1;
        articles[articleLink].earnings += msg.value;
        owner.transfer(msg.value);
        
        emit ArticleViewed(_title, _authorName, msg.sender, msg.value);
    }
    
    function getArticleLink(string memory _title, string memory _authorName) public pure returns (string memory) {
        string memory articleLink = generateArticleLink(_title, _authorName);
        return articleLink;
    }
    
    function withdrawEarnings() public onlyOwner {
        uint contractBalance = address(this).balance;
        owner.transfer(contractBalance);
    }
}
