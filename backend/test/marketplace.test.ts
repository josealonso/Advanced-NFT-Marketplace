import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { assert } from "console";
import { ethers } from "hardhat";
import { NFTMarketplacev2, NFTMarketplacev2__factory } from "../typechain";

/* test/sample-test.js */
describe("NFTMarket", function () {
  let NFTMarketplace: NFTMarketplacev2__factory;
  let nftMarketplace: NFTMarketplacev2;
  const BASE_URI = "ipfs://.......";
  // const [deployer, client, manufacturer] = await ethers.getSigners();
  let deployer: SignerWithAddress;
  let client: SignerWithAddress;
  let manufacturer: SignerWithAddress;
  const TEST_TOKEN = "0x2d7882beDcbfDDce29Ba99965dd3cdF7fcB10A1e"; // On Mumbai

  before(async function () {
    console.log("BEFORE =========");
    NFTMarketplace = await ethers.getContractFactory("NFTMarketplacev2")
    nftMarketplace = await NFTMarketplace.deploy("AYT", "Ayed Clubs", BASE_URI);
    await nftMarketplace.deployed();
    // [deployer, client, manufacturer] = await ethers.getSigners();
    console.log("aaaaaaaaaaaAA =========");
    // const PRICE = ethers.BigNumber.from("2");
    // let item = await nftMarketplace.setMarketItem(1, deployer.address, client.address, PRICE, true);
  });

  it("Should not be able to buy a NFT if he has no enough money", async function () {
    [deployer, client, manufacturer] = await ethers.getSigners();
    const PRICE = ethers.BigNumber.from("2");
    const TOKEN_ID = 2;
    let item = await nftMarketplace.setMarketItem(1, deployer.address, client.address, PRICE, true);
    let newTokenId = await nftMarketplace.connect(client).buyItem("", TOKEN_ID);
    console.log("The result is ", newTokenId);
    // assert(newTokenId, 3.toString());
  })
});

//   it("Should create and execute market sales", async function () {
//     /* deploy the marketplace */

//     let listingPrice = await (await nftMarketplace.getListingPrice()).toString();
//     // listingPrice = listingPrice.toString()

//     const auctionPrice = ethers.utils.parseUnits('1', 'ether')

//     /* create two tokens */
//     await nftMarketplace.createToken("https://www.mytokenlocation.com", auctionPrice, { value: listingPrice })
//     await nftMarketplace.createToken("https://www.mytokenlocation2.com", auctionPrice, { value: listingPrice })

//     const [_, buyerAddress] = await ethers.getSigners()

//     /* execute sale of token to another user */
//     await nftMarketplace.connect(buyerAddress).createMarketSale(1, { value: auctionPrice })

//     /* resell a token */
//     await nftMarketplace.connect(buyerAddress).resellToken(1, auctionPrice, { value: listingPrice })

//     /* query for and return the unsold items */
//     let items = await nftMarketplace.fetchMarketItems();
//     let items2 = await Promise.all(items.map(async i => {
//       const tokenUri = await nftMarketplace.tokenURI(i.tokenId)
//       let item = {
//         price: i.price.toString(),
//         tokenId: i.tokenId.toString(),
//         seller: i.seller,
//         owner: i.owner,
//         tokenUri
//       }
//       return item
//     }))
//     console.log('items: ', items2)
//   })
// })

