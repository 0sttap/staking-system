const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

/**
 * Initialize the contract
 * @returns {ethers.Contract}
 */
function initContract() {
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);

  const contractJsonPath = path.join(
    __dirname,
    "../../../contracts/out/Stake.sol/Stake.json"
  );

  const contractJson = JSON.parse(fs.readFileSync(contractJsonPath, "utf8"));
  const contractABI = contractJson.abi;

  const contractAddress = process.env.CONTRACT_ADDRESS;

  const contract = new ethers.Contract(contractAddress, contractABI, provider);

  return contract;
}

module.exports = initContract;
