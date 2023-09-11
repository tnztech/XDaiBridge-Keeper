// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BridgeKeeper} from "../src/BridgeKeeper.sol";


contract DeploymentScript is Script {


    function run() public {
        address manager = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        BridgeKeeper keeper = new BridgeKeeper(manager);
        vm.stopBroadcast();
        console2.log(address(keeper));
    }
}
