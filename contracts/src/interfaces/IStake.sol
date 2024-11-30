// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface IStake {
    event RewardsDistributed(uint256 rewardAmount);
    event RewardsClaimed(address indexed user, uint256 rewardAmount);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    error RewardIntervalNotReached();
    error NoStakedTokens();
    error CannotStakeZeroAmount();
    error CannotWithdrawZeroAmount();
    error CannotDistributeZeroAmount();
    error NoRewardsToClaim();

    /// @notice Distribute rewards to stakers.
    /// @param rewardAmount The amount of rewards to distribute.
    function distributeRewards(uint256 rewardAmount) external;

    /// @notice Stake tokens.
    /// @param amount The amount of tokens to stake.
    function stake(uint256 amount) external;

    /// @notice Withdraw staked tokens.
    /// @param amount The amount of tokens to withdraw.
    function withdraw(uint256 amount) external;

    /// @notice Claim rewards.
    function claimRewards() external;

    /// @notice Withdraw staked tokens and claim rewards.
    function exit() external;

    /// @notice Get stakers.
    /// @return stakers The list of stakers.
    function getStakers() external view returns (address[] memory stakers);
}
