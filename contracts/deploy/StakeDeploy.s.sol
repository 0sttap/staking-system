// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {Script} from "../lib/forge-std/src/Script.sol";

import {Stake} from "../src/Stake.sol";
import {ERC20Mock} from "../test/mock/ERC20Mock.sol";

/**
    forge script deploy/StakeDeploy.s.sol \
        --ffi --broadcast --rpc-url https://network.ambrosus-test.io --legacy
 */
contract StakeDeploy is Script {
    function run() public returns (address stake) {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        ERC20Mock stakingToken = new ERC20Mock();
        ERC20Mock rewardToken = new ERC20Mock();

        stake = address(new Stake(address(stakingToken), address(rewardToken)));
        vm.stopBroadcast();
    }
}
