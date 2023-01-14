const { ethers } = require("hardhat");
const { GENERIC_HANDLER_GOERLI } = require("../constants");

async function main() {
  const genericHandlerGoerli = GENERIC_HANDLER_GOERLI;
  const firstContract = await ethers.getContractFactory("MyContract");
  const deployedFirstContract = await firstContract.deploy(
    genericHandlerGoerli
  );
  await deployedFirstContract.deployed();

  console.log("First contract address :", deployedFirstContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
