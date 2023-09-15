// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./Setup.t.sol";

contract GastTest is SetupTest {
    event UserRequestForAffirmation(address recipient, uint256 value);

    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function claimable() public view returns (uint256) {
        return (bridge.interestAmount(dai) >= bridge.minInterestPaid(dai)) ? bridge.interestAmount(dai) : 0;
    }

    function bridgeBalance() public view returns (uint256) {
        return IERC20(dai).balanceOf(address(bridge));
    }

    /*//////////////////////////////////////////////////////////////
                        CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testDirect_Claim() external {
        bridge.payInterest(dai, 10000 ether);
    }

    function testMultisend_ClaimAndRefill() external {
        deal(dai, address(bridge), 5 ether);
        bytes memory callData1 = abi.encodeWithSignature("payInterest(address,uint256)", dai, uint256(10000 ether));
        bytes memory callData2 = abi.encodeWithSignature("refillBridge()");
        bytes memory call1 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData1.length), callData1);
        bytes memory call2 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData2.length), callData2);
        bytes memory callsEncoded = abi.encodePacked(call1, call2);
        multisend.multiSend(callsEncoded);
    }

    function testMulticall_ClaimAndRefill() external {
        deal(dai, address(bridge), 5 ether);
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](2);
        calls[0] = IMulticall3.Call3(
            address(bridge), false, abi.encodeWithSignature("payInterest(address,uint256)", dai, 10000 ether)
        );
        calls[1] = IMulticall3.Call3(address(bridge), false, abi.encodeWithSignature("refillBridge()"));
        multicall3.aggregate3(calls);
    }

    function testMultisend_ClaimAndInvest() external {
        deal(dai, address(bridge), 1000 ether);
        bytes memory callData1 = abi.encodeWithSignature("payInterest(address,uint256)", dai, uint256(10000 ether));
        bytes memory callData2 = abi.encodeWithSignature("investDai()");
        bytes memory call1 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData1.length), callData1);
        bytes memory call2 =
            abi.encodePacked(uint8(0), address(bridge), uint256(0), uint256(callData2.length), callData2);
        bytes memory callsEncoded = abi.encodePacked(call1, call2);
        multisend.multiSend(callsEncoded);
    }

    function testMulticall_ClaimAndInvest() external {
        deal(dai, address(bridge), 1000 ether);
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](2);
        calls[0] = IMulticall3.Call3(
            address(bridge), false, abi.encodeWithSignature("payInterest(address,uint256)", dai, 10000 ether)
        );
        calls[1] = IMulticall3.Call3(address(bridge), false, abi.encodeWithSignature("investDai()"));
        multicall3.aggregate3(calls);
    }
}
