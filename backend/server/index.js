const express = require("express");
const mongoose = require("mongoose");
const { BigNumber } = require("ethers");
const initContract = require("./init/contract");
const initMongoose = require("./init/mongoose");
const initializeData = require("./init/data");

const { Decimal128 } = mongoose.Types;

const app = express();
const port = process.env.PORT || 3000;

const contract = initContract();

const { ContractInfo, UserInfo } = initMongoose();

contract.on("Staked", async (staker, amount) => {
  let user = await UserInfo.findOne({ address: staker });
  const contractInfo = await ContractInfo.findOne({});

  if (user) {
    const userStakedBN = BigNumber.from(user.staked.toString());
    user.staked = Decimal128.fromString(userStakedBN.add(amount).toString());
  } else {
    user = new UserInfo({
      address: staker,
      staked: Decimal128.fromString(amount.toString()),
      availableRewards: Decimal128.fromString("0"),
    });

    contractInfo.stakersCount++;
  }

  await user.save();

  const totalStakedBN = BigNumber.from(contractInfo.totalStaked.toString());

  contractInfo.totalStaked = Decimal128.fromString(
    totalStakedBN.add(amount).toString()
  );

  await contractInfo.save();
});

contract.on("Withdrawn", async (staker, amount) => {
  const user = await UserInfo.findOne({ address: staker });
  const contractInfo = await ContractInfo.findOne({});

  if (user) {
    const userStakedBN = BigNumber.from(user.staked.toString());
    const rest = userStakedBN.sub(amount);
    user.staked = Decimal128.fromString(rest.toString());
    await user.save();

    const totalStakedBN = BigNumber.from(contractInfo.totalStaked.toString());

    contractInfo.totalStaked = Decimal128.fromString(
      totalStakedBN.sub(amount).toString()
    );

    if (rest.isZero()) {
      contractInfo.stakersCount--;

      await UserInfo.deleteOne({ address: staker });
    }

    await contractInfo.save();
  }
});

contract.on("RewardsDistributed", async (amount) => {
  const contractInfo = await ContractInfo.findOne({});
  contractInfo.lastRewardTime = new Date();

  await contractInfo.save();

  const users = await UserInfo.find({});
  const totalStakedBN = BigNumber.from(contractInfo.totalStaked.toString());

  const rewardPerToken = amount
    .mul(BigNumber.from("100000000000000000"))
    .div(totalStakedBN);

  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const userStakedBN = BigNumber.from(user.staked.toString());

    const reward = rewardPerToken
      .mul(userStakedBN)
      .div(BigNumber.from("100000000000000000"));

    const userRewardBN = BigNumber.from(user.availableRewards.toString());

    user.availableRewards = Decimal128.fromString(
      userRewardBN.add(reward).toString()
    );

    await user.save();
  }
});

contract.on("RewardsClaimed", async (staker) => {
  const user = await UserInfo.findOne({ address: staker });

  user.availableRewards = Decimal128.fromString("0");

  await user.save();
});

app.listen(port, async () => {
  console.log(`Server running at http://localhost:${port}`);
  await initializeData(contract, ContractInfo, UserInfo);
});
