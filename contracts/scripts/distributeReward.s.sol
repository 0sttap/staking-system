// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {IStake} from "../src/interfaces/IStake.sol";

/*
    forge script scripts/distributeReward.s.sol \
        --ffi --broadcast --rpc-url https://network.ambrosus-test.io --legacy
*/
contract DistributeRewardScript is Script {
    IStake stake = IStake(vm.envAddress("CONTRACT_ADDRESS"));
    uint256 amountToDistribute = 10000e18;
    address rewardToken = vm.envAddress("REWARD_TOKEN");

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        IERC20(rewardToken).approve(address(stake), amountToDistribute);
        stake.distributeRewards(amountToDistribute);
        vm.stopBroadcast();
    }
}