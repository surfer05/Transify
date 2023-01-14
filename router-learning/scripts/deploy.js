const {ethers}  = require("hardhat");
const {  GOERLI_TESTNET_ADDRESS , DEST_GAS_LIMIT} = require("../constants/index.js");

async function main() {
  const goerliTesnetAddress = GOERLI_TESTNET_ADDRESS;
  const destGasLimit = DEST_GAS_LIMIT;
  const firstContract = await ethers.getContractFactory("MyContract")
  const deployedFirstContract = await firstContract.deploy(
    "",goerliTesnetAddress,destGasLimit
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
