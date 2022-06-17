import { expect } from "chai";
import { ethers } from "hardhat";
import { NFTMarketplace, NFTMarketplace__factory } from "../typechain";

/* test/sample-test.js */
describe("NFTMarket", function () {
  let NFTMarketplace: NFTMarketplace__factory;
  let nftMarketplace: NFTMarketplace;
  before(async function () {
    NFTMarketplace = await ethers.getContractFactory("NFTMarketplace")
    nftMarketplace = await NFTMarketplace.deploy()
    await nftMarketplace.deployed()
  });

  it("Should create and execute market sales", async function () {
    /* deploy the marketplace */

    let listingPrice = await (await nftMarketplace.getListingPrice()).toString();
    // listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('1', 'ether')

    /* create two tokens */
    await nftMarketplace.createToken("https://www.mytokenlocation.com", auctionPrice, { value: listingPrice })
    await nftMarketplace.createToken("https://www.mytokenlocation2.com", auctionPrice, { value: listingPrice })

    const [_, buyerAddress] = await ethers.getSigners()

    /* execute sale of token to another user */
    await nftMarketplace.connect(buyerAddress).createMarketSale(1, { value: auctionPrice })

    /* resell a token */
    await nftMarketplace.connect(buyerAddress).resellToken(1, auctionPrice, { value: listingPrice })

    /* query for and return the unsold items */
    let items = await nftMarketplace.fetchMarketItems();
    let items2 = await Promise.all(items.map(async i => {
      const tokenUri = await nftMarketplace.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items2)
  })
})

// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();

//     expect(await greeter.greet()).to.equal("Hello, world!");

//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

//     // wait until the transaction is mined
//     await setGreetingTx.wait();

//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });
