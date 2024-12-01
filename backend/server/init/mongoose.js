const mongoose = require("mongoose");

/**
 * Initialize mongoose connection and models for ContractInfo and UserInfo
 * @returns {Object} {ContractInfo, UserInfo}
 */
function initMongoose() {
  const contractInfoSchema = new mongoose.Schema({
    totalStaked: mongoose.Schema.Types.Decimal128,
    lastRewardTime: Date,
    stakersCount: Number,
  });

  const userInfoSchema = new mongoose.Schema({
    address: String,
    staked: mongoose.Schema.Types.Decimal128,
    availableRewards: mongoose.Schema.Types.Decimal128,
  });

  const ContractInfo = mongoose.model("Contract_Info", contractInfoSchema);
  const UserInfo = mongoose.model("User_Info", userInfoSchema);

  mongoose.connect(process.env.MONGODB_URL);

  return { ContractInfo, UserInfo };
}

module.exports = initMongoose;
