//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./DataStructures.sol";
import "./Marketplace.sol";

contract CollectionFactory is Ownable {
    address public collectionAddress;
    // EnumerableSet.AddressSet private _collectionAddresses;
    address[] private _collectionAddresses;

    event CreateCollection(address newCollectionAddress, address owner);

    /*
     * @dev Minimal proxy pattern
     */
    function createCollection(
        string memory _name,
        string memory _symbol,
        string memory _metadataURI,
        uint256 _makerRoyalties,
        address _makerAddress,
        NftToken[] memory _nftsInCollection
    ) external returns (address) {
        NftCollection memory newCollection;
        address clonedCollectionAddress = Clones.clone(collectionAddress);
        // Populate the "instance" of NftCollection
        // This field value is unique, so it's the collection identifier
        newCollection.nftContractAddress = clonedCollectionAddress;
        newCollection.name = _name;
        newCollection.symbol = _symbol;
        newCollection.metadataURI = _metadataURI;
        newCollection.makerRoyalties = _makerRoyalties;
        newCollection.makerAddress = _makerAddress;
        newCollection.nftsInCollection = _nftsInCollection;
        //  TODO ---> initialize the 721 contract
        _collectionAddresses.push(clonedCollectionAddress);
        emit CreateCollection(clonedCollectionAddress, msg.sender);
        return clonedCollectionAddress;
    }

    function getNumberOfCollections() public view returns (uint256) {
        return _collectionAddresses.length;
    }

    function getCollectionAddressAtIndex(uint256 index)
        public
        view
        returns (address)
    {
        return _collectionAddresses[index];
    }
}
