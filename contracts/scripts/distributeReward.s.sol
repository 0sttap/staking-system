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
    IStake stake = IStake(0x73B4A6E4E229AD89135343D4A1bC07e4D1789CCb);
    uint256 amountToDistribute = 10000e18;
    address rewardToken = 0xDBB98f31Bc6b6DB303E8cb761f1b5A96B1016d64;

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        IERC20(rewardToken).approve(address(stake), amountToDistribute);
        stake.distributeRewards(amountToDistribute);
        vm.stopBroadcast();
    }
}