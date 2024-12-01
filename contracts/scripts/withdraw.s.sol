// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {IStake} from "../src/interfaces/IStake.sol";

/*
    forge script scripts/withdraw.s.sol \
        --ffi --broadcast --rpc-url https://network.ambrosus-test.io --legacy
*/
contract WithdrawScript is Script {
    IStake stake = IStake(vm.envAddress("CONTRACT_ADDRESS"));
    uint256 user1AmountToWithdraw = 10e18;
    uint256 user2AmountToWithdraw = 2e18;
    address stakingToken = vm.envAddress("STAKING_TOKEN");

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        
        uint256 user2Pk;
        try vm.envUint("PRIVATE_KEY_2") returns (uint256 pk_) {
            user2Pk = pk_;
        } catch {
            user2Pk = 0; 
        }

        vm.startBroadcast(pk);
        stake.withdraw(user1AmountToWithdraw);
        vm.stopBroadcast();

        if (user2Pk != 0) {
            vm.startBroadcast(user2Pk);
            stake.withdraw(user2AmountToWithdraw);
            vm.stopBroadcast();
        }
    }
}