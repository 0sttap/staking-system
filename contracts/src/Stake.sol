// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {EnumerableSet} from "openzeppelin-contracts/utils/structs/EnumerableSet.sol";

import {IStake} from "./interfaces/IStake.sol";

contract Stake is Ownable, IStake {
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    uint256 public totalStaked;
    uint256 public lastRewardTime;
    uint256 public constant REWARD_INTERVAL = 1 days;

    EnumerableSet.AddressSet internal _stakers;

    mapping(address => uint256) public userStake;
    mapping(address => uint256) public userReward;

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    /// @inheritdoc IStake
    function distributeRewards(uint256 _rewardAmount) external onlyOwner {
        require(block.timestamp >= lastRewardTime + REWARD_INTERVAL, RewardIntervalNotReached());
        require(totalStaked > 0, NoStakedTokens());
        require(_rewardAmount > 0, CannotDistributeZeroAmount());

        rewardToken.transferFrom(msg.sender, address(this), _rewardAmount);

        uint256 accRewardPerToken = _rewardAmount * 1e18 / totalStaked;
        uint256 length = _stakers.length();

        address[] memory stakers = _stakers.values();

        for (uint256 i; i < length; i++) {
            address staker = stakers[i];
            uint256 reward = userStake[staker] * accRewardPerToken / 1e18;

            userReward[staker] += reward;
        }

        lastRewardTime = block.timestamp;

        emit RewardsDistributed(_rewardAmount);
    }

    /// @inheritdoc IStake
    function stake(uint256 _amount) external {
        require(_amount > 0, CannotStakeZeroAmount());

        totalStaked += _amount;
        userStake[msg.sender] += _amount;
        _stakers.add(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);
    }


    /// @inheritdoc IStake
    function withdraw(uint256 _amount) external {
        _withdraw(_amount);
    }

    /// @inheritdoc IStake
    function claimRewards() external {
        _claim();
    }

    /// @inheritdoc IStake
    function exit() external {
        _withdraw(userStake[msg.sender]);
        _claim();
    }

    /// @inheritdoc IStake
    function getStakers() external view returns (address[] memory stakers) {
        stakers = _stakers.values();
    }

    function getStakersCount() external view returns (uint256 count) {
        count = _stakers.length();
    }

    function _withdraw(uint256 _amount) internal {
        require(_amount > 0, CannotWithdrawZeroAmount());

        uint256 updatedAmount = userStake[msg.sender] - _amount;

        if (updatedAmount == 0) {
            _stakers.remove(msg.sender);
        }

        totalStaked -= _amount;
        userStake[msg.sender] = updatedAmount;

        stakingToken.transfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function _claim() internal {
        uint256 reward = userReward[msg.sender];

        require(reward > 0, NoRewardsToClaim());

        userReward[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);

        emit RewardsClaimed(msg.sender, reward);
    }
}
