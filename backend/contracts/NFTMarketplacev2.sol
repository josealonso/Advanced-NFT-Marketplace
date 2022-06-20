//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplacev2 is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    // @dev owner is not payable because only stable coins can be used
    address owner;
    address constant TEST_TOKEN_ON_MATIC =
        0x2d7882beDcbfDDce29Ba99965dd3cdF7fcB10A1e;
    ERC20 testTokenContract = ERC20(TEST_TOKEN_ON_MATIC);

    struct MarketItem {
        uint256 collectionId;
        address makerAddress; // the manufacturer
        address owner;
        uint256 price;
        // bool sold;
        // string product_line;
        // string qr_code;
    } // Metadata --> product_line, qr_code, description
    MarketItem marketItem;
    mapping(uint256 => MarketItem) public idToMarketItem;

    // @dev It means written to the blochchain
    event MarketItemBought(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold // ??
    );

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) ERC721(name, symbol) {
        // tokenURI = baseURI;
        owner = msg.sender;
    }

    function setMarketItem(
        uint256 tokenId,
        address seller,
        address itemOwner,
        uint256 price,
        bool sold
    ) public onlyMaker {
        marketItem = MarketItem(tokenId, seller, itemOwner, price, sold);
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

    function getUSDCBalance(address _address) public view returns (uint256) {
        return testTokenContract.balanceOf(_address);
    }

    // @dev Mint the NFT token and transfer it to the buyer
    // @dev The "lazy minting" technique is used
    // function buyItem(string memory tokenURI, MarketItem memory _item)
    function buyItem(string memory tokenURI, uint256 tokenId)
        external
        returns (uint256)
    {
        // TODO ---> royalties
        // make sure the buyer has money enough
        marketItem = idToMarketItem[tokenId];
        if (marketItem.sold) {
            revert("This item is not on sale");
        }
        uint256 itemPrice = marketItem.price;
        if (getUSDCBalance(msg.sender) < 1.5 ether) {
            //  itemPrice) {
            revert("Not enough money");
        }
        // https://stackoverflow.com/questions/71941928/how-to-transfer-erc20-tokens-to-another-address-using-solidity
        // TODO approve and transfer the ERC-20 token
        // testTokenContract.approve(msg.sender, itemPrice);
        // transferFrom() requires approve + transfer and smart contracts cannot approve itself.
        testTokenContract.transfer(address(this), itemPrice);

        // the NFT is minted
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        // _safeMint(address(this), newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        // transferMarketItem(newTokenId, itemPrice);
        return newTokenId;
    }

    // TODO
    function addCollection() public {}

    function transferMarketItem(uint256 tokenId, uint256 price) private {
        // require(price > 0, "Price must be at least 1 wei");
        // require(
        //     msg.value == listingPrice,
        //     "Price must be equal to listing price"
        // );
        // MarketItem memory marketItem; // = new MarketItem();  // "new" is only for contracts
        // @dev the seller is the own marketplace only for new products
        setMarketItem(tokenId, address(this), msg.sender, price, true);
        idToMarketItem[tokenId] = marketItem;
        // idToMarketItem[tokenId] = MarketItem;
        //     tokenId,
        //     payable(msg.sender),
        //     payable(address(this)),
        //     price,
        //     true // "sold" field
        // );

        // _transfer(msg.sender, address(this), tokenId);
        _transfer(address(this), msg.sender, tokenId); // 'ERC721: transfer from incorrect owner'
        emit MarketItemBought(tokenId, address(this), msg.sender, price, true);
    }

    function createMarketSale(uint256 tokenId) public payable {
        // Is it needed ?
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {}

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
