// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTCollection is ERC721URIStorage {
    uint256 public maxNumOfItems;
    string public productName;
    address public makerAddress;
    uint256 public tokenCount; // counter

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxNumOfItems,
        string memory _productName,
        address _makerAddress
    ) ERC721(_name, _symbol) {
        maxNumOfItems = _maxNumOfItems;
        productName = _productName;
        makerAddress = _makerAddress;
        // more ERC721 variables can be initialized here
    }

    function mint(string memory _tokenURI) external returns (uint256) {
        tokenCount++;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);
        return tokenCount;
    }

    function getNumOfCollectionItems() external view returns (uint256) {
        return maxNumOfItems;
    }

    function getCollectionAddress() external view returns (address) {
        return address(this);
    }

    function getMakerAddress() external view returns (address) {
        return makerAddress;
    }

    function getProductName() external view returns (string memory) {
        return productName;
    }
}
