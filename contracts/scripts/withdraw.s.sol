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
    IStake stake = IStake(0x73B4A6E4E229AD89135343D4A1bC07e4D1789CCb);
    uint256 user1AmountToWithdraw = 100e18;
    uint256 user2AmountToWithdraw = 25e18;
    address user2Address = 0x5F49CfE21B12ffD7fE0dDd11E91b2636F86D7358;
    address stakingToken = 0xE647737933e51510Ba0D870F3B7b2bD73915aF59;

    function run() public {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        uint256 user2Pk = vm.envUint("PRIVATE_KEY_2");

        vm.startBroadcast(pk);
        stake.withdraw(user1AmountToWithdraw);
        vm.stopBroadcast();

        vm.startBroadcast(user2Pk);
        stake.withdraw(user2AmountToWithdraw);
        vm.stopBroadcast();
    }
}