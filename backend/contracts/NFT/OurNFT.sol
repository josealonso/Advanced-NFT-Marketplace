//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./EnumerableNFT.sol";
import "../Marketplace.sol";

// If you’re writing a contract that needs to receive ERC721 tokens,
// you’ll want to include thie IERC721Receiver interface.
contract OurNFT is ReentrancyGuard, Initializable, EnumerableNFT {
    using Counters for Counters.Counter;

    // EVENTS ---> To be changed
    event NftMinted(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address indexed mintedTo,
        string tokenUri
    );
    event NftOnSale(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event NftSaleCancel(
        address indexed nftContractAddress,
        uint256 indexed tokenId
    );
    event NftBought(
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        address boughtBy,
        uint256 price
    );

    // STATE VARS
    address public authorAddr;
    address payable public marketplaceAddr;
    // address payable public woofyContractAddr;
    string public description;
    // generate a unique token id for each token we mint
    Counters.Counter private _tokenIdCounter;

    /**
     * MODIFIERS   // TODO
     */

    // name and symbol values should be retrieved from the proxy contract
    function initialize(
        string calldata _name,
        string calldata _symbol,
        string calldata _description,
        address payable _marketplaceAddr
    )
        public
        payable
        // address payable _woofyContractAddr
        initializer
    {
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        authorAddr = tx.origin;
        marketplaceAddr = _marketplaceAddr;
        description = _description;
        // woofyContractAddr = _woofyContractAddr;
        _tokenIdCounter.increment();
    }

/************************ TO BE CHANGED ***************************/
    // Mint NFT
    function mintNft(string calldata _metadataUri)
        external
        nonReentrant
    // onlyNftCollectionAuthor
    {
        uint256 currentTokenId = _tokenIdCounter.current();
        _mint(authorAddr, currentTokenId);
        _setTokenURI(currentTokenId, _metadataUri);
        _tokenIdCounter.increment();
        // emit NftMinted(address(this), currentTokenId, authorAddr, _metadataUri);
    }

    // Put up NFT for sale
    function putNftForSale(uint256 _id, uint256 _price)
        external
        nonReentrant
        // validTokenId(_id)
        // onlyNftOwner(_id)
        // nftNotOnSale(_id)
    {
        _tokenOnSaleIdToPrice[_id] = _price;
        approve(address(this), _id);
        emit NftOnSale(address(this), _id, _price);
    }

    // Cancel NFT for sale
    function cancelNftForSale(uint256 _id)
        external
        nonReentrant
        // validTokenId(_id)
        // nftOnSale(_id)
        // onlyNftOwner(_id)
    {
        delete _tokenOnSaleIdToPrice[_id];
        emit NftSaleCancel(address(this), _id);
    }

    // Buy NFT (when woofys owned by author num is not known)
    function buyNftForSale(uint256 _id)
        external
        payable
        nonReentrant
        // validTokenId(_id)
        // notNftOwner(_id)
        // nftOnSale(_id)
        returns (uint256 price)
    {
        uint256 priceForSale = _tokenOnSaleIdToPrice[_id];
        require(
            msg.value == priceForSale
            // strcat("INCORRECT VALUE SENT; SEND: ", priceForSale.toString())
        );
        address ownerOfNft = payable(ownerOf(_id));
        this.safeTransferFrom(ownerOfNft, msg.sender, _id);
        delete _tokenOnSaleIdToPrice[_id];

        // uint256 woofysOwnedByAuthor = Woofy(woofyContractAddr).balanceOf(authorAddr);
        // uint256 commissionPercentage = 3 - (woofysOwnedByAuthor / 20); // For every WOOFY owned by author, reduce commission percentage by 0.05%
        // uint256 commissionAmount = (msg.value * commissionPercentage) / 100;
        // uint256 amountToTransferToTokenOwner = msg.value - commissionAmount;

        // bool success;
        // (success, ) = payable(marketplaceAddr).call{value: commissionAmount}(
        //     ""
        // );
        // require(
        //     success,
        //     "TRANSFER OF AMOUNT TO MARKETPLACE OWNER NOT SUCCESSFUL"
        // );
        // (success, ) = ownerOfNft.call{value: amountToTransferToTokenOwner}("");
        // require(success, "TRANSFER OF AMOUNT TO TOKEN OWNER NOT SUCCESSFUL");
        emit NftBought(address(this), _id, tx.origin, priceForSale);
        return priceForSale;
    }
    // Secondary Royalties on Rarible ---> https://ethereum-blockchain-developer.com/121-erc721-secondary-sales-royalties-erc2981/05-rarible-secondary-sales-revenue-custom-contract/
}
