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

    function run() external returns (string memory TX_LOG, uint256 amountRelayed) {
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
        uint256 claimThreshold = vm.envUint("CLAIM_THRESHOLD");

        multisend = IMultiSendCallOnly(0x40A2aCCbd92BCA938b02010E17A5b8929b49130D);
        bridge = IXDaiForeignBridge(bridgeAddr);
        dai = bridge.erc20token();

        /*//////////////////////////////////////////////////////////////
                                OPERATIONS
        //////////////////////////////////////////////////////////////*/

        uint256 balance = IERC20(dai).balanceOf(address(bridge));
        uint256 amountClaimable = claimable();
        uint256 minInterestClaimed = bridge.minInterestPaid(dai);
        uint256 minCashThreshold = bridge.minCashThreshold(dai);

        // ENV VARIABLE and LIMIT CHECKS
        if (refillThreshold > minCashThreshold) return ("REFILL_THRESHOLD must be lower", 0);
        else if (investThreshold < minCashThreshold) return ("INVEST_THRESHOLD must be lower", 0);
        else if (claimThreshold > minCashThreshold) return ("CLAIM_THRESHOLD must be lower", 0);
        else if (amountClaimable < minInterestClaimed) return ("Claimable amount too low", 0);
        else if (amountClaimable < bridge.minPerTx()) return ("Claimable amount too low", 0);

        amountClaimable = (amountClaimable > bridge.maxPerTx()) ? bridge.maxPerTx() : amountClaimable;
        // Initial Logging

        address operator = vm.rememberKey(deployerPrivateKey);
        console2.log("Operator address: %s", address(operator));
        console2.log("Amount available to claim: %e", amountClaimable);
        console2.log("Amount of DAI in the bridge: %e", balance);

        // Action Selection

        vm.startBroadcast(deployerPrivateKey);

        // If balance is high enough to invest... claim and invest
        if (balance > investThreshold) {
            claimAndInvest();
            return ("Invested and Relayed DAI", amountClaimable);
        }
        // If balance is low enough and we should refill... claim and refill
        else if (balance < refillThreshold) {
            claimAndRefill();
            return ("Refilled and Relayed DAI:", amountClaimable);
        }
        // If balance is neither good for claim or refill - claim if amount claimable higher than the claimThreshold
        else if (amountClaimable > claimThreshold) {
            bridge.payInterest(dai, amountClaimable);
            return ("Simply Relayed DAI", amountClaimable);
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
