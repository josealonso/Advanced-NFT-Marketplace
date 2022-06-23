//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
