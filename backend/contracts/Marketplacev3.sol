//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/structs/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMarketplace.sol";

/**
 * Based on https://github.com/captain-woof/woofy-market
 * For the first MVP, let's assume there is only one maker with only one collection.
 */

/**
 * @dev An integer is the collection identifier.
 * This variable relates the collection identifier and the collection data.
 * This is commented because it produces a compile error.
 * mapping (uint256 => CollectionData) public idToCollectionData;
 */

// all solidity code is transactional.  All pieces must run successfully
// The only exception is when you use try/catch

contract Marketplace is IMarketplace, ReentrancyGuard, Ownable {
    // using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => NftCollection) public idToNftCollection;
    EnumerableSet.AddressSet private _nftCollectionAddresses;
    uint256 private marketplaceRoyalties;
    address newNftCollection;

    constructor(address _newNftCollection) {
        newNftCollection = _newNftCollection;
    }

    /*
     * @dev Minimal proxy pattern
     */
    function createNftCollectionContract(NftCollection memory _newNftCollection)
        external
        override
        nonReentrant
    {
        address clonedNftCollectionAddress = Clones.clone(newNftCollection);
        _newNftCollection.name;
        // TODO populate the new collection with data
        _nftCollectionAddresses.add(clonedNftCollectionAddress);
        uint256 collectionId = 22;
        emit CreateNftCollectionContract(
            clonedNftCollectionAddress,
            collectionId
        );
    }

    /**
     * @dev Adds a collection to the marketplace.
     * Emits a {AddCollection} event.
     */

    function setCollectionURI(uint256 collectionId, string memory collectionURI)
        external
        override
    {
        NftCollection storage nftCollection = idToNftCollection[collectionId];
        nftCollection.metadataURI = collectionURI;
    }

    /**
     * @dev Change the price of an existing token.
     * Action performed on behalf of the maker.
     * Emits a {UpdateTokenPrice} event.
     */
    function updateTokenPrice(
        uint256 _collectionId,
        uint256 _tokenId,
        // NftToken calldata _nftToken,
        uint256 _newPrice
    ) public override {
        // NftToken calldata nftToken = _nftToken;   // Would "memory" instead of "calldta" work ?
        NftCollection storage nftCollection = idToNftCollection[_collectionId];
        nftCollection.nftsInCollection[_tokenId].price = _newPrice;
        emit UpdateTokenPrice(_collectionId, _tokenId, _newPrice);
    }

    /**
     * @dev Change the wallet address of a maker that is already registered on the marketplace.
     * Action performed on behalf of the maker.
     * Emits a {UpdateMakerAddress} event.
     */
    function updateMakerAddress(
        uint256 collectionId,
        address oldAddress,
        address newAddress
    ) public override {}

    /**
     * @dev Returns the price of the `tokenId` token of the `collectionId` collection.
     *
     *  * Requirements:
     *
     * - `collectionId` must exist.
     * - `tokenId` must exist.
     */
    function getTokenPrice(uint256 collectionId, uint256 tokenId)
        public
        override
        returns (uint256)
    {}

    function getMakerAddress(uint256 collectionId)
        public
        override
        returns (address)
    {}

    function buyItem(uint256 collectionId, uint256 tokenId)
        external
        override
        returns (uint256)
    {}

    /**
     * @dev Returns only the tokens that a user has purchased.
     */
    function fetchMyNFTs()
        external
        view
        override
        returns (uint256 collectionId, uint256[] memory tokenIds)
    {}

    function setMakerRoyalties(uint256 collectionId, uint256 _makerPercentage)
        external
        override
    {
        NftCollection storage nftCollection = idToNftCollection[collectionId];
        nftCollection.makerRoyalties = _makerPercentage; // TODO
    }

    function setMarketplaceRoyalties(uint256 _marketplacePercentage)
        external
        override
    {
        marketplaceRoyalties = _marketplacePercentage; // TODO
    }

    function getMarketplaceRoyalties()
        external
        view
        override
        returns (uint256 marketplacePercentage)
    {
        return marketplaceRoyalties;
    }

    function getMakerRoyalties(uint256 collectionId)
        external
        override
        returns (uint256 makerPercentage)
    {}

    function getTokensForSale(uint256 collectionID)
        external
        override
        returns (uint256[] memory tokenIds)
    {}
}
