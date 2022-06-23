//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * For the first MVP, let's assume there is only one maker with only one collection.
 */
struct NftToken {
    uint256 tokenId;
    string metadataUri;
    address owner;
    uint256 price;
}

/**
 * @dev An array is easier than a mapping/dictionary, although the mapping is more efficient.
 */
struct NftCollection {
    uint256 nftCollectionId;
    string name;
    string symbol;
    string metadataURI;
    uint256 makerRoyalties; // this field is optional
    address makerAddress;
    address nftContractAddress;
    NftToken[] nftsInCollection;
}

// EnumerableSet.AddressSet private _nftCollectionAddresses;
// uint256 private marketplaceRoyalties;

interface IMarketplace {
    /**
     * @dev Emitted when a collection is added to the marketplace.
     * A contract is created per collection.
     */
    event CreateNftCollectionContract(
        address indexed collectionAddress,
        uint256 indexed collectionId
    );

    /**
     * @dev Emitted when a token price is modified.
     */
    event UpdateTokenPrice(
        uint256 indexed collectionId,
        uint256 indexed tokenId,
        uint256 indexed newPrice
    );

    /**
     * @dev Emitted when the royalties of an existing collection are modified.
     */
    event UpdateMakerRoyalties(
        uint256 indexed collectionId,
        uint256 makerPercentage
    );

    /**
     * @dev Emitted when the royalties of the marketplace are modified.
     */
    event UpdateMarketplaceRoyalties(uint256 marketpacePercentage);

    /**
     * @dev Emitted when a maker address is updated.
     */
    event UpdateMakerAddress(
        uint256 indexed collectionId,
        address indexed newAddress
    );

    /**
     * @dev Adds a collection to the marketplace.
     * Emits a {CreateNftCollectionContract} event.
     */
    function createNftCollectionContract(
        NftCollection memory _newNftCollection
        // address makerAddress,
        // string memory collectionURI,
        // uint256 sellerRoyalties
    ) external;

    function setCollectionURI(uint256 collectionId, string memory collectionURI)
        external;

    /**
     * @dev Change the price of an existing token.
     * Action performed on behalf of the maker.
     * Emits a {UpdateTokenPrice} event.
     */
    function updateTokenPrice(
        uint256 collectionId,
        // NftToken calldata _nftToken,
        uint256 tokenId,
        uint256 newPrice
    ) external;

    function setMakerRoyalties(uint256 collectionId, uint256 makerPercentage)
        external;

    function setMarketplaceRoyalties(uint256 marketplacePercentage) external;

    /**
     * @dev Change the wallet address of a maker that is already registered on the marketplace.
     * Action performed on behalf of the maker.
     * Emits a {UpdateMakerAddress} event.
     */
    function updateMakerAddress(
        uint256 collectionId,
        address oldAddress,
        address newAddress
    ) external;

    /**
     * @dev Returns the price of the `tokenId` token of the `collectionId` collection.
     *
     *  * Requirements:
     *
     * - `collectionId` must exist.
     * - `tokenId` must exist.
     */
    function getTokenPrice(uint256 collectionId, uint256 tokenId)
        external
        returns (uint256);

    function getMakerAddress(uint256 collectionId) external returns (address);

    function getMarketplaceRoyalties()
        external
        returns (uint256 marketplacePercentage);

    function getMakerRoyalties(uint256 collectionId)
        external
        returns (uint256 makerPercentage);

    function buyItem(uint256 collectionId, uint256 tokenId)
        external
        returns (uint256);

    /**
     * @dev Returns only the tokens of a `collectionId` collection that can be sold.
     * Assume there is no secondary market (the NFTs can't be reselled).
     * This information is needed by the frontend because the token is not minted until it's sold ("lazy minting" technique)
     */
    function getTokensForSale(uint256 collectionID)
        external
        returns (uint256[] memory tokenIds);

    /**
     * @dev Returns only the tokens that a user has purchased.
     */
    function fetchMyNFTs()
        external
        view
        returns (uint256 collectionId, uint256[] memory tokenIds);
}
