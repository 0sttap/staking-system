// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {IStake} from "../src/interfaces/IStake.sol";

/*
    forge script scripts/claimRewards.s.sol \
        --ffi --broadcast --rpc-url https://network.ambrosus-test.io --legacy
*/
contract ClaimRewardsScript is Script {
    IStake stake = IStake(0x73B4A6E4E229AD89135343D4A1bC07e4D1789CCb);

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        stake.claimRewards();
        vm.stopBroadcast();
    }
}