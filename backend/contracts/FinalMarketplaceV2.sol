// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTCollection.sol";

/*
 * 1.- Deploy at least one NFTCollection contract.
 * 2.- Execute the `addCollection` function once per collection.
 * 3.- Execute the `chooseCollection` function once.  ---> NO
 * 3.- The first collection of the array will be used.
 */
contract FinalMarketplaceV2 is ReentrancyGuard, Ownable {
    address payable public immutable feeAccount;
    NFTCollection[] public nftCollectionsArray;
    uint256 public immutable feePercent;
    uint256 public collectionItems;

    MarketItem[] itemsForSale;
    MarketItem[] itemsOwnedByUser;
    uint256 public itemCount;

    struct MarketItem {
        uint256 itemId;
        IERC721 nftCollection; // this parameter is a ERC721 contract, so all the ERC721 functions can be used here
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }
    mapping(uint256 => MarketItem) public items;
    mapping(NFTCollection => uint256) public collectionToItemId;

    event MarketItemAdded(
        // "indexed" applied to a field allows to use that field as a filter
        uint256 itemId,
        address indexed nftCollection,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );

    event MarketItemPurchase(
        uint256 itemId,
        address indexed nftCollection,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    constructor(uint256 _feePercent) {
        // script ---> .....deploy(1)
        feeAccount = payable(msg.sender); // the account that receives the fees
        feePercent = _feePercent;
        // The first collection of the array will be used.
        uint256 collectionId = collectionToItemId[nftCollectionsArray[0]];
        collectionItems = nftCollectionsArray[collectionId]
            .getNumOfCollectionItems();
    }

    function addCollection(address _nftCollectionAddress) public {
        NFTCollection nftCollection = NFTCollection(_nftCollectionAddress);
        nftCollectionsArray.push(nftCollection);
    }

    // Not used
    function chooseCollection(uint256 _collectionIndex) public {
        uint256 collectionId = collectionToItemId[
            nftCollectionsArray[_collectionIndex]
        ];
        collectionItems = nftCollectionsArray[collectionId]
            .getNumOfCollectionItems();
        // MarketItem storage currentMarketItem = items[collectionItems];
    }

    function addMarketItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        if (_price <= 0) {
            revert("Price must be greater than zero");
        }
        itemCount++;
        // transfer nft. For this to work, the user has to call `approve()` first
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        items[itemCount] = MarketItem(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        emit MarketItemAdded(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }

    function buyMarketItem(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getTotalPrice(_itemId);
        MarketItem storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(msg.value == _totalPrice, "not enough money");
        require(!item.sold, "item already sold");
        // pay seller and feeAccount
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        item.sold = true;
        // transfer nft to buyer
        item.nftCollection.transferFrom(
            address(this),
            msg.sender,
            item.tokenId
        );
        emit MarketItemPurchase(
            _itemId,
            address(item.nftCollection),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function withdraw() public onlyOwner {
        // TODO
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return (items[_itemId].price * (100 - feePercent / 100));
    }

    function getItemsForSale() public returns (MarketItem[] memory) {
        for (uint256 i = 0; i < collectionItems; ) {
            if (!items[i].sold) {
                itemsForSale.push(items[i]);
            }
            unchecked {
                i++;
            }
        }
        return itemsForSale;
    }

    function getItemsOwnedByUser() public returns (MarketItem[] memory) {
        delete itemsOwnedByUser;
        for (uint256 i = 0; i < collectionItems; ) {
            if (items[i].seller == msg.sender) {
                // Not sure
                itemsOwnedByUser.push(items[i]);
            }
            unchecked {
                i++;
            }
        }
        return itemsOwnedByUser;
    }
}
