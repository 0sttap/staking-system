// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {IStake} from "../src/interfaces/IStake.sol";

/*
    forge script scripts/stake.s.sol \
        --ffi --broadcast --rpc-url https://network.ambrosus-test.io --legacy
*/
contract StakeScript is Script {
    IStake stake = IStake(vm.envAddress("CONTRACT_ADDRESS"));
    uint256 amountToStake = 100e18;
    uint256 user2AmountToStake = 25e18;
    address stakingToken = vm.envAddress("STAKING_TOKEN");

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        uint256 user2Pk;
        address user2Address;
        try vm.envUint("PRIVATE_KEY_2") returns (uint256 pk_) {
            user2Pk = pk_;
            user2Address = vm.addr(user2Pk);
        } catch {
            user2Pk = 0; 
        }

        vm.startBroadcast(pk);
        IERC20(stakingToken).approve(address(stake), amountToStake);
        
        if (user2Pk != 0) IERC20(stakingToken).transfer(user2Address, user2AmountToStake);

        stake.stake(amountToStake);
        vm.stopBroadcast();

        if (user2Pk != 0) {
            vm.startBroadcast(user2Pk);
            IERC20(stakingToken).approve(address(stake), user2AmountToStake);
            stake.stake(user2AmountToStake);
            vm.stopBroadcast();
        }
    }
}