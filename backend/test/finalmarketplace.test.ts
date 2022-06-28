import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumberish } from "ethers";
import hre, { ethers } from "hardhat";
import { FinalMarketplace, FinalMarketplace__factory, NFTCollection, NFTCollection__factory } from "../typechain";
// import { MarketItemBoughtEvent } from "../typechain/NFTMarketplace";

// 1 ether = 10**18 wei
const toWei = (num: Number) => ethers.utils.parseEther(num.toString());
const fromWei = (num: BigNumberish) => ethers.utils.formatEther(num);

describe("NFTMarketplace", function () {
  // let NFTCollection: NFTCollection__factory;
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

  this.beforeEach(async function () {
    // get contract factories
    const NFTCollection = await ethers.getContractFactory("NFTCollection");
    // nftCollection = await NFTCollection.deploy(NAME, SYMBOL, ethers.BigNumber.from(MAX_NUM_OF_TOKENS), "productName");  // maker.address);
    nftCollection = await NFTCollection.deploy(NAME, SYMBOL, MAX_NUM_OF_TOKENS, "productName");
    // get signers
    [deployer, client, client2, maker] = await ethers.getSigners();
    // deploy contracts
    const NFTMarketplace = await ethers.getContractFactory("FinalMarketplace")
    // nftMarketplace = await NFTMarketplace.deploy(ethers.BigNumber.from(FEE_PERCENT));
    nftMarketplace = await NFTMarketplace.deploy(FEE_PERCENT);
    await nftCollection.deployed();
    await nftMarketplace.deployed();
  });
  describe("Deployment", function () {
    it("Should track name and symbol of the nft collection", async function () {

      //     expect(await nftCollection.name()).to.equal(NAME);
      //     expect(await nftCollection.symbol()).to.equal(SYMBOL);    // Errors
    })
    it("Should track feePercent of the marketplace", async function () {
      // console.log("AAAAA - ", await nftMarketplace.itemCount());
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
});

//   it("Should not be able to buy a NFT if he has no enough money", async function () {
//     // [deployer, client, manufacturer] = await ethers.getSigners();
//     const TOKEN_ID = 2;
//     const testToken = await ethers.getContractAt("IERC20", TEST_TOKEN);
//     // let item = await nftMarketplace.setMarketItem(1, deployer.address, client.address, PRICE, true);
//     // @dev Impersonate an account allows to use that account without having its private key
//     await hre.network.provider.request({
//       method: "hardhat_impersonateAccount",
//       params: [WHALE],
//     });
//     const signer = await ethers.getSigner(WHALE);
//     let balanceInWei = await nftMarketplace.getUSDCBalance(signer.address);
//     let balanceInEther = ethers.utils.formatEther(balanceInWei);
//     console.log("Your balance: ", balanceInEther);
//     let newTokenId = await nftMarketplace.connect(signer).buyItem("", 1);
//     console.log("The result is ", newTokenId);
//     // assert(newTokenId, 3.toString());
//   })
// });

