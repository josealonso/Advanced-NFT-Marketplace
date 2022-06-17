import { ethers } from "hardhat";
import { writeFileSync } from "fs";

async function main() {
  // URL from where we can extract the metadata for the NFTs
  const metadataURL = "ipfs://QmZc7jp32oZNbaSGBLbMib4GU5YnGesvudHcE3o7EVqdjs/";
  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so punksContract here is a factory for instances of our Punks contract.
  */
  const marketplaceContract = await ethers.getContractFactory("NFTMarketplace");

  // deploy the contract
  // const deployedMarketplaceContract = await marketplaceContract.deploy(metadataURL);
  const deployedMarketplaceContract = await marketplaceContract.deploy();
  await deployedMarketplaceContract.deployed();
  // print the address of the deployed contract
  console.log("Marketplace Contract Address:", deployedMarketplaceContract.address);

  writeFileSync('../frontend/config.ts', `export const marketplaceAddress = "${deployedMarketplaceContract.address}"
  `);
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
