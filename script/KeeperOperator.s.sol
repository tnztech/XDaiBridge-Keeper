// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {IXDaiForeignBridge} from "../src/interfaces/IXDaiForeignBridge.sol";
import "../src/interfaces/IMultiSendCallOnly.sol";
import "forge-std/interfaces/IERC20.sol";

contract KeeperOperatorScript is Script {

    IMultiSendCallOnly multisend;
    IXDaiForeignBridge bridge;
    address dai;


    function run() external {
        /*//////////////////////////////////////////////////////////////
                                KEY MANAGEMENT
        //////////////////////////////////////////////////////////////*/

        uint256 deployerPrivateKey = 0;
        string memory mnemonic = vm.envString("MNEMONIC");

        if (bytes(mnemonic).length > 30) {
            deployerPrivateKey = vm.deriveKey(mnemonic, 0);
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        address bridgeAddr = vm.envAddress("BRIDGE_ADDR");
        uint256 investThreshold = vm.envUint("INVEST_THRESHOLD");
        uint256 refillThreshold = vm.envUint("REFILL_THRESHOLD");
        
        multisend = IMultiSendCallOnly(0x40A2aCCbd92BCA938b02010E17A5b8929b49130D);
        bridge = IXDaiForeignBridge(bridgeAddr);
        dai = bridge.erc20token();

        /*//////////////////////////////////////////////////////////////
                                OPERATIONS
        //////////////////////////////////////////////////////////////*/

        uint256 amount = claimable();
        uint256 balance = IERC20(dai).balanceOf(address(bridge));
        require(amount > 0, "Not claimable");

        vm.startBroadcast(deployerPrivateKey);
        address operator = vm.rememberKey(deployerPrivateKey);
        console2.log("Operator address: %s", address(operator));

        if (amount > 0) {
            if (balance > investThreshold) {
                claimAndInvest();
                console2.log("Claimed and Invested");
            } else if (balance < refillThreshold) {
                claimAndRefill();
                console2.log("Claimed and Refilled");
            } else {
                bridge.payInterest(dai, 1000000 ether);
                console2.log("Just Claimed");
            }
            console2.log("Relaying %e DAI to Gnosis Chain", amount + bridge.minInterestPaid(dai));
        }

        vm.stopBroadcast();
    }
 
    function claimable() public view returns (uint256) {
        return (bridge.interestAmount(dai) >= bridge.minInterestPaid(dai)) ? bridge.interestAmount(dai) : 0;
    }

    function claimAndRefill() internal {
        bytes memory callData1 = abi.encodeWithSignature("payInterest(address,uint256)", dai, uint256(1000000 ether));
        bytes memory callData2 = abi.encodeWithSignature("refillBridge()");
        bytes memory call1 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData1.length), callData1);
        bytes memory call2 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData2.length), callData2);
        bytes memory callsEncoded = abi.encodePacked(call1, call2);
        multisend.multiSend(callsEncoded);
    }

    function claimAndInvest() internal {
        bytes memory callData1 = abi.encodeWithSignature("payInterest(address,uint256)", dai, uint256(1000000 ether));
        bytes memory callData2 = abi.encodeWithSignature("investDai()");
        bytes memory call1 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData1.length), callData1);
        bytes memory call2 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData2.length), callData2);
        bytes memory callsEncoded = abi.encodePacked(call1, call2);
        multisend.multiSend(callsEncoded);
    }
}
