import { ethers } from "hardhat";
import { writeFileSync } from "fs";

async function main() {
  const FEE_PERCENT = 1;

  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so marketplaceContract here is a factory for instances of our FinalMarketplace contract.
  */
  const marketplaceContract = await ethers.getContractFactory("FinalMarketplace");

  // deploy the contract
  const deployedMarketplaceContract = await marketplaceContract.deploy(FEE_PERCENT);
  await deployedMarketplaceContract.deployed();
  // print the address of the deployed contract
  console.log("Marketplace Contract Address:", deployedMarketplaceContract.address);

  // To be changed
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

