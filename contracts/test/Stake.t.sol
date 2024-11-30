// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";

import {Stake, IStake} from "../src/Stake.sol";
import {ERC20Mock} from "./mock/ERC20Mock.sol";

contract StakeTest is Test {
    Stake internal _stake;

    ERC20Mock internal _stakingToken;
    ERC20Mock internal _rewardToken;

    address internal _user1 = makeAddr("user1");
    address internal _user2 = makeAddr("user2");

    function setUp() public {
        _stakingToken = new ERC20Mock();
        _rewardToken = new ERC20Mock();

        _stake = new Stake(address(_stakingToken), address(_rewardToken));

        _rewardToken.approve(address(_stake), type(uint256).max);

        _stakingToken.transfer(_user1, 1000e18);
        _stakingToken.transfer(_user2, 1000e18);
    }

    function test_stake() public {
        uint256 amountToStake = 100e18;
        uint256 contractBalanceBefore = _stakingToken.balanceOf(address(_stake));
        uint256 userBalanceBefore = _stakingToken.balanceOf(_user1);

        _doStake(_user1, amountToStake);

        uint256 contractBalanceAfter = _stakingToken.balanceOf(address(_stake));
        uint256 userBalanceAfter = _stakingToken.balanceOf(_user1);

        assertEq(contractBalanceAfter, contractBalanceBefore + amountToStake);
        assertEq(userBalanceAfter, userBalanceBefore - amountToStake);

        assertEq(_stake.totalStaked(), amountToStake);
        assertEq(_stake.userStake(_user1), amountToStake);

        address[] memory stakers = _stake.getStakers();
        assertEq(stakers.length, 1);
        assertEq(stakers[0], _user1);
    }

    function test_withdraw() public {
        uint256 amountToStake = 100e18;
        uint256 amountToWithdraw = 50e18;

        _doStake(_user1, amountToStake);

        uint256 contractBalanceBefore = _stakingToken.balanceOf(address(_stake));
        uint256 userBalanceBefore = _stakingToken.balanceOf(_user1);

        vm.prank(_user1);
        vm.expectEmit();
        emit IStake.Withdrawn(_user1, amountToWithdraw);
        _stake.withdraw(amountToWithdraw);

        uint256 contractBalanceAfter = _stakingToken.balanceOf(address(_stake));
        uint256 userBalanceAfter = _stakingToken.balanceOf(_user1);

        assertEq(contractBalanceAfter, contractBalanceBefore - amountToWithdraw);
        assertEq(userBalanceAfter, userBalanceBefore + amountToWithdraw);

        assertEq(_stake.totalStaked(), amountToStake - amountToWithdraw);
        assertEq(_stake.userStake(_user1), amountToStake - amountToWithdraw);

        address[] memory stakers = _stake.getStakers();
        assertEq(stakers.length, 1);

        vm.prank(_user1);
        _stake.withdraw(amountToWithdraw);

        assertEq(_stake.totalStaked(), 0);
        assertEq(_stake.userStake(_user1), 0);

        stakers = _stake.getStakers();
        assertEq(stakers.length, 0);
    }

    function test_distributeRewards() public {
        uint256 amountToStake = 100e18;
        uint256 amountToDistribute = 10000e18;

        _doStake(_user1, amountToStake);
        _doStake(_user2, amountToStake);

        _distribute(amountToDistribute);

        uint256 rewardPerToken = amountToDistribute * 1e18 / _stake.totalStaked();
        uint256 user1Reward = rewardPerToken * amountToStake / 1e18;
        uint256 user2Reward = rewardPerToken * amountToStake / 1e18;

        assertEq(_stake.userReward(_user1), user1Reward);
        assertEq(_stake.userReward(_user2), user2Reward);

        assertEq(_stake.lastRewardTime(), block.timestamp);
    }

    function test_claimRewards() public {
        test_distributeRewards();

        uint256 user1Reward = _stake.userReward(_user1);
        uint256 user2Reward = _stake.userReward(_user2);

        uint256 user1BalanceBefore = _rewardToken.balanceOf(_user1);
        uint256 user2BalanceBefore = _rewardToken.balanceOf(_user2);
        uint256 contractBalanceBefore = _rewardToken.balanceOf(address(_stake));

        vm.prank(_user1);
        vm.expectEmit();
        emit IStake.RewardsClaimed(_user1, user1Reward);
        _stake.claimRewards();

        vm.prank(_user2);
        vm.expectEmit();
        emit IStake.RewardsClaimed(_user2, user2Reward);
        _stake.claimRewards();

        uint256 user1BalanceAfter = _rewardToken.balanceOf(_user1);
        uint256 user2BalanceAfter = _rewardToken.balanceOf(_user2);
        uint256 contractBalanceAfter = _rewardToken.balanceOf(address(_stake));

        assertEq(user1BalanceAfter, user1BalanceBefore + user1Reward);
        assertEq(user2BalanceAfter, user2BalanceBefore + user2Reward);
        assertEq(contractBalanceAfter, contractBalanceBefore - user1Reward - user2Reward);

        assertEq(_stake.userReward(_user1), 0);
        assertEq(_stake.userReward(_user2), 0);
    }

    function test_exit() public {
        uint256 amountToStake = 100e18;
        uint256 amountToDistribute = 10000e18;

        _doStake(_user1, amountToStake);

        _distribute(amountToDistribute);

        uint256 user1Reward = _stake.userReward(_user1);

        uint256 userRewardTokenBalanceBefore = _rewardToken.balanceOf(_user1);
        uint256 contractRewardBalanceBefore = _rewardToken.balanceOf(address(_stake));

        uint256 user1StakingTokenBalanceBefore = _stakingToken.balanceOf(_user1);
        uint256 contractStakingTokenBalanceBefore = _stakingToken.balanceOf(address(_stake));

        vm.prank(_user1);
        _stake.exit();

        uint256 userRewardBalanceAfter = _rewardToken.balanceOf(_user1);
        uint256 contractRewardBalanceAfter = _rewardToken.balanceOf(address(_stake));

        uint256 user1StakingTokenBalanceAfter = _stakingToken.balanceOf(_user1);
        uint256 contractStakingTokenBalanceAfter = _stakingToken.balanceOf(address(_stake));

        assertEq(userRewardBalanceAfter, userRewardTokenBalanceBefore + user1Reward);
        assertEq(contractRewardBalanceAfter, contractRewardBalanceBefore - user1Reward);

        assertEq(user1StakingTokenBalanceAfter, user1StakingTokenBalanceBefore + amountToStake);
        assertEq(contractStakingTokenBalanceAfter, contractStakingTokenBalanceBefore - amountToStake);

        assertEq(_stake.userReward(_user1), 0);
        assertEq(_stake.userReward(_user2), 0);

        assertEq(_stake.totalStaked(), 0);
        assertEq(_stake.userStake(_user1), 0);
        assertEq(_stake.userStake(_user2), 0);
    }

    ////////////////////////////
    ///// REVERTS //////////////
    ////////////////////////////

    function test_cannotStakeZeroAmount() public {
        vm.expectRevert(IStake.CannotStakeZeroAmount.selector);
        _stake.stake(0);
    }

    function test_cannotWithdrawZeroAmount() public {
        vm.expectRevert(IStake.CannotWithdrawZeroAmount.selector);
        _stake.withdraw(0);
    }

    function test_cannotWithdrawMoreAmountThanStaked() public {
        vm.prank(_user1);
        vm.expectRevert();
        _stake.withdraw(1);

        _doStake(_user1, 100e18);

        vm.prank(_user1);
        vm.expectRevert();
        _stake.withdraw(200e18);
    }

    function test_rewardIntervalNotReached() public {
        vm.expectRevert(IStake.RewardIntervalNotReached.selector);
        _stake.distributeRewards(100e18);
    }

    function test_noStakedTokens() public {
        vm.warp(block.timestamp + 1 days);

        vm.expectRevert(IStake.NoStakedTokens.selector);
        _stake.distributeRewards(100e18);
    }

    function test_cannotDistributeZeroAmount() public {
        _doStake(_user1, 1);

        vm.warp(block.timestamp + 1 days);

        vm.expectRevert(IStake.CannotDistributeZeroAmount.selector);
        _stake.distributeRewards(0);
    }

    function test_noRewardsToClaim() public {
        // Trying to claim rewards without staking & distributing
        vm.prank(_user1);
        vm.expectRevert(IStake.NoRewardsToClaim.selector);
        _stake.claimRewards();

        // Trying to claim rewards without distributing
        _doStake(_user1, 100e18);
        
        vm.startPrank(_user1);
        vm.expectRevert(IStake.NoRewardsToClaim.selector);
        _stake.claimRewards();

        _stake.withdraw(100e18);
        vm.stopPrank();

        // Trying to claim rewards without staking
        _doStake(_user2, 1);
        _distribute(100e18);

        vm.prank(_user1);
        vm.expectRevert(IStake.NoRewardsToClaim.selector);
        _stake.claimRewards();
    }

    ////////////////////////////
    ///// INTERNALS ////////////
    ////////////////////////////

    function _doStake(address staker, uint256 amount) internal {
        vm.startPrank(staker);
        _stakingToken.approve(address(_stake), amount);

        vm.expectEmit();
        emit IStake.Staked(staker, amount);
        _stake.stake(amount);
        vm.stopPrank();
    }

    function _distribute(uint256 amount) internal {
        vm.warp(block.timestamp + 1 days);

        _rewardToken.approve(address(_stake), amount);

        vm.expectEmit();
        emit IStake.RewardsDistributed(amount);
        _stake.distributeRewards(amount);
    }
}
