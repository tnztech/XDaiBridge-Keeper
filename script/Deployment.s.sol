// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BridgeKeeper} from "../src/BridgeKeeper.sol";


contract DeploymentScript is Script {

    function run() external {

        /*//////////////////////////////////////////////////////////////
                                KEY MANAGEMENT
        //////////////////////////////////////////////////////////////*/

        uint256 deployerPrivateKey = 0;
        string memory mnemonic = vm.envString('MNEMONIC');

        if (bytes(mnemonic).length > 30) {
            deployerPrivateKey = vm.deriveKey(mnemonic, 0);
        } else {
            deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        }

        address manager = vm.envAddress("KEEPER_MANAGER");

        vm.startBroadcast(deployerPrivateKey);
        address deployer = vm.rememberKey(deployerPrivateKey);
        console2.log('Deployer: %s', deployer);

        /*//////////////////////////////////////////////////////////////
                                DEPLOYMENTS
        //////////////////////////////////////////////////////////////*/

        BridgeKeeper keeper = new BridgeKeeper(manager);
        console2.log('Deployed BridgeKeeper: %s', address(keeper));
        console2.log('Condigured Manager: %s', keeper.MANAGER());

        vm.stopBroadcast();
    }
}
