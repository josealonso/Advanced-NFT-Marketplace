//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * For the first MVP, let's assume there is only one maker with only one collection.
 */

struct CollectionData {
    uint256 maxNumOfTokens;
    address makerAddress;
    string collectionURI;
    // mapping(uint256 => uint256) idToTokenPrice;
}

/**
 * @dev An integer is the collection identifier.
 * This variable relates the collection identifier and the collection data.
 * This is commented because it produces a compile error.
 * mapping (uint256 => CollectionData) public idToCollectionData;
 */

interface IMarketplace {
    /**
     * @dev Emitted when a collection is added to the marketplace.
     */
    event AddCollection(uint256 indexed collectionId);

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
    event UpdateRoyalties(
        uint256 indexed collectionId,
        uint256 sellerPercentage,
        uint256 marketplacePercentage
    );

    /**
     * @dev Emitted when a maker address is updated.
     */
    event UpdateMakerAddress(
        uint256 indexed collectionId,
        address indexed newAddress
    );

    /**
     * @dev Adds a collection to the marketplace.
     * Emits a {AddCollection} event.
     */
    // function addCollection(uint256 collectionId) external;
    function addCollection(
        uint256 maxNumOfTokens,
        address makerAddress,
        string memory collectionURI,
        // Starting from solidity 0.7.0, mappings can only live in storage
        // mapping(uint256 => uint256) memory idToTokenPrice     // Compile error
        mapping(uint256 => uint256) storage idToTokenPrice
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
        uint256 tokenId,
        uint256 newPrice
    ) external;

    function setRoyalties(
        uint256 collectionId,
        uint256 sellerPercentage,
        uint256 marketplacePercentage
    ) external;

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

    function getMaxNumOfTokens(uint256 collectionId) external returns (uint256);

    function getRoyalties(uint256 collectionId)
        external
        returns (uint256 sellerPercentage, uint256 marketplacePercentage);

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
