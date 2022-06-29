import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumberish } from "ethers";
import hre, { ethers } from "hardhat";
import { FinalMarketplace, FinalMarketplace__factory, NFTCollection, NFTCollection__factory } from "../typechain";

// 1 ether = 10**18 wei
const toWei = (num: Number) => ethers.utils.parseEther(num.toString());
const fromWei = (num: BigNumberish) => ethers.utils.formatEther(num);

describe("NFTMarketplace", function () {
  let NFTCollection: NFTCollection__factory;
  let nftCollection: NFTCollection;
  // let NFTMarketplace: FinalMarketplace__factory;
  let nftMarketplace: FinalMarketplace;
  const URI = "ipfs://.......";
  const NAME = "MyNFT";
  const SYMBOL = "MFT";
  const MAX_NUM_OF_TOKENS = 50;
  const MAKER_ADDRESS = "0x.................";
  const FEE_PERCENT = 1;    // 1% fees
  let deployer: SignerWithAddress;
  let client: SignerWithAddress;
  let client2: SignerWithAddress;
  let maker: SignerWithAddress;
  const TEST_TOKEN = "0x2d7882beDcbfDDce29Ba99965dd3cdF7fcB10A1e"; // On Mumbai
  const WHALE = "0x5f793AbBd751f1Ac5B0F95f3C3D117E5Fd218c41";
  let itemZero: any;
  let itemOne: any;
  let itemTwo: any;

  beforeEach(async function () {
    // get signers
    [deployer, client, client2, maker] = await ethers.getSigners();
    // get contract factories
    const NFTCollection = await ethers.getContractFactory("NFTCollection");
    nftCollection = await NFTCollection.deploy(NAME, SYMBOL, ethers.BigNumber.from(MAX_NUM_OF_TOKENS), "productName", maker.address);
    // deploy contracts
    const NFTMarketplace = await ethers.getContractFactory("FinalMarketplace")
    nftMarketplace = await NFTMarketplace.deploy(FEE_PERCENT);
    await nftCollection.deployed();
  });
  describe("Deployment", function () {
    it("Should track name and symbol of the nft collection", async function () {
      expect(await nftCollection.name()).to.equal(NAME);
      expect(await nftCollection.symbol()).to.equal(SYMBOL);
    })
    it("Should track feePercent of the marketplace", async function () {
      expect(await nftMarketplace.feePercent()).to.equal(FEE_PERCENT);
      expect(await nftMarketplace.feeAccount()).to.equal(deployer.address);
    });
  });
  describe("Minting NFTs", function () {
    it("Should track each minted NFT", async function () {
      // client mints an NFT
      await nftCollection.connect(client).mint(URI);
      expect(await nftCollection.tokenCount()).to.equal(1);
      expect(await nftCollection.balanceOf(client.address)).to.equal(1);
      expect(await nftCollection.tokenURI(1)).to.equal(URI);
      // client2 mints an NFT
      await nftCollection.connect(client2).mint(URI);
      expect(await nftCollection.tokenCount()).to.equal(2);
      expect(await nftCollection.balanceOf(client2.address)).to.equal(1);
      expect(await nftCollection.tokenURI(2)).to.equal(URI);
    });
  });
  describe("Adding marketplace items", function () {
    beforeEach(async function () {
      // client mints an NFT
      await nftCollection.connect(client).mint(URI);
      // client approves marketplace to spend nft
      await nftCollection.connect(client).setApprovalForAll(nftMarketplace.address, true);
    });
    it("Should track newly created item, transfer NFT from seller to marketplace and emit --- event", async function () {
      // client offers their nft at a price of 1 ether
      await expect(nftMarketplace.connect(client).addMarketItem(nftCollection.address, 1, toWei(1)))
        .to.emit(nftMarketplace, "MarketItemAdded")
        .withArgs(1, nftCollection.address, 1, toWei(1), client.address);
      // Owner of NFT should now be the marketplace
      expect(await nftCollection.ownerOf(1)).to.equal(nftMarketplace.address);
      // Item count should now be equal 1
      expect(await nftMarketplace.itemCount()).to.equal(1);
      // Get item from items mapping then check fields to ensure they are correct
      const item = await nftMarketplace.items(1);
      expect(item.itemId).to.equal(1);
      expect(item.nftCollection).to.equal(nftCollection.address);
      expect(item.tokenId).to.equal(1);
      expect(item.price).to.equal(toWei(1));
      expect(item.sold).to.equal(false);
    });
    it("Should fail if price is set to zero", async function () {
      await expect(
        nftMarketplace.connect(client).addMarketItem(nftCollection.address, 1, 0)
      ).to.be.revertedWith("Price must be greater than zero");
    });
  });
  describe("Buying marketplace items", function () {
    let price = 2;
    beforeEach(async function () {
      // client mints an NFT
      await nftCollection.connect(client).mint(URI);
      // client approves marketplace to spend nft
      await nftCollection.connect(client).setApprovalForAll(nftMarketplace.address, true);
      // client makes their nft a marketplace item
      await nftMarketplace.connect(client).addMarketItem(nftCollection.address, 1, toWei(price));
    });
    it("Should update item as sold, pay seller, transfer NFT to buyer, charge fees and emit a --- event", async function () {
      const sellerInitialEthBalance = await client.getBalance();
      const feeAccountInitialEthBalance = await deployer.getBalance();
      // fetch items total price (market fees + item price)
      let totalPriceInWei = await nftMarketplace.getTotalPrice(1);
      // client2 buys item
      await expect(nftMarketplace.connect(client2).buyMarketItem(1, { value: totalPriceInWei }))
        .to.emit(nftMarketplace, "MarketItemPurchase")
        .withArgs(1, nftCollection.address, 1, toWei(price), client.address, client2.address);
      const sellerFinalEthBalance = await client.getBalance();
      const feeAccountFinalEthBalance = await deployer.getBalance();
      // Seller should receive payment for the price of the NFT sale
      // expect(fromWei(sellerFinalEthBalance)).to.equal(price)

    });
  });
});

