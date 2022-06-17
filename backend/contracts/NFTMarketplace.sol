//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    // @dev not payable because only stable coins can be used
    address owner;
    address constant TEST_TOKEN_ON_MATIC =
        0x2d7882beDcbfDDce29Ba99965dd3cdF7fcB10A1e;
    ERC20 testTokenContract = ERC20(TEST_TOKEN_ON_MATIC);

    struct MarketItem {
        uint256 tokenId;
        address seller; // the manufacturer
        address owner;
        uint256 price;
        bool sold;
        // string product_line;
        // string qr_code;
    }
    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) ERC721(name, symbol) {
        baseTokenURI = baseURI;
        owner = msg.sender;
    }

    /* Updates the listing price of the item */
    function updateListingPrice(uint256 _listingPrice) public payable {
        require(
            owner == msg.sender,
            "Only marketplace owner can update listing price."
        );
        // listingPrice = _listingPrice;
    }

    /* Returns the listing price of the item */
    function getListingPrice(uint256 itemId) public view returns (uint256) {
        if (!idToMarketItem[itemId].sold) {
            revert("The item does not exist");
        }
        return idToMarketItem[itemId].price;
    }

    // @dev Mint the NFT token and transfer it to the buyer
    function buyItem(MarketItem memory _item) external {
        // make sure the buyer has money enough
        if (testTokenContract.balanceOf(msg.sender) < _item.price) {
            revert("Not enough money");
        }
        // the NFT is minted
         _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId); 
    }
}
