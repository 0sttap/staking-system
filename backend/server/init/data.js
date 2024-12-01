const mongoose = require("mongoose");
const { Decimal128 } = mongoose.Types;

/**
 * Update contract info
 * @param {ethers.Contract} contract 
 * @param {Object} ContractInfo 
 */
const updateContractInfo = async (contract, ContractInfo) => {
  try {
    const totalStaked = await contract.totalStaked();
    const lastRewardTime = await contract.lastRewardTime();
    const stakersCount = await contract.getStakersCount();

    const contractInfo = new ContractInfo({
      totalStaked: Decimal128.fromString(totalStaked.toString()),
      lastRewardTime: new Date(lastRewardTime * 1000),
      stakersCount,
    });

    await ContractInfo.deleteMany({});
    await contractInfo.save();
    console.log("Contract info updated");
  } catch (error) {
    console.error("Error updating contract info:", error);
  }
};

/**
 * Update user info
 * @param {String} address 
 * @param {ethers.Contract} contract 
 * @param {Object} UserInfo 
 */
const updateUserInfo = async (address, contract, UserInfo) => {
  try {
    const staked = await contract.userStake(address);
    const availableRewards = await contract.userReward(address);

    const userInfo = new UserInfo({
      address,
      staked: Decimal128.fromString(staked.toString()),
      availableRewards: Decimal128.fromString(availableRewards.toString()),
    });

    await UserInfo.deleteMany({ address });
    await userInfo.save();
    console.log(`User info updated for address: ${address}`);
  } catch (error) {
    console.error(`Error updating user info for address ${address}:`, error);
  }
};

/**
 * Initialize data in the database
 * @param {ethers.Contract} contract 
 * @param {Object} ContractInfo 
 * @param {Object} UserInfo 
 */
const initializeData = async (contract, ContractInfo, UserInfo) => {
  await updateContractInfo(contract, ContractInfo);
  const stakers = await contract.getStakers();
  for (const staker of stakers) {
    await updateUserInfo(staker, contract, UserInfo);
  }
};

module.exports = initializeData;