// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BridgeKeeper} from "../src/BridgeKeeper.sol";
import {IXDaiForeignBridge} from "../src/interfaces/IXDaiForeignBridge.sol";


contract KeeperOperatorScript is Script {

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

        BridgeKeeper keeper = BridgeKeeper(vm.envAddress("KEEPER_ADDR"));
        address config_bridge = vm.envAddress("BRIDGE_ADDR");

        vm.startBroadcast(deployerPrivateKey);
        address operator = vm.rememberKey(deployerPrivateKey);
        console2.log('Connected to operator address: %s', address(operator));
        if (operator == keeper.MANAGER()){
                console2.log('Operator is also the keeper Manager - use aa diferent wallet');
        }

        /*//////////////////////////////////////////////////////////////
                                OPERATIONS
        //////////////////////////////////////////////////////////////*/

        IXDaiForeignBridge bridge = IXDaiForeignBridge(address(keeper.bridge()));
        require(address(bridge) == config_bridge);
        uint256 amount = claimable(bridge, keeper.dai());

        if (amount > 0){
            keeper.claim();
            console2.log('Relaying %e DAI to Gnosis Chain', amount + bridge.minInterestPaid(keeper.dai()));

        }

        vm.stopBroadcast();
    }

    function claimable(IXDaiForeignBridge bridge, address dai) public view returns (uint256) {
        return
            (bridge.interestAmount(dai) >= bridge.minInterestPaid(dai))
                ? bridge.interestAmount(dai)
                : 0;
    }
}
