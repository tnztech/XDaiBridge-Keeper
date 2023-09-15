// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";
import "forge-std/interfaces/IMulticall3.sol";
import "../src/interfaces/IXDaiForeignBridge.sol";
import "../src/interfaces/IMultiSendCallOnly.sol";

contract SetupTest is Test {
    address public initializer = address(17);
    address public dai;
    address public bridgeAddress = 0x8659Cf2273438f9b5C1Eb367Def45007a7A16a24;
    IXDaiForeignBridge public bridge;
    uint256 public globalTime;

    IMulticall3 public multicall3 = IMulticall3(0xcA11bde05977b3631167028862bE2a173976CA11);
    IMultiSendCallOnly public multisend = IMultiSendCallOnly(0x40A2aCCbd92BCA938b02010E17A5b8929b49130D);

    function setUp() public payable {
        console.log("chainId %s", block.chainid);
        console.log("block %s", block.number);

        bridge = IXDaiForeignBridge(bridgeAddress);

        globalTime = block.timestamp;

        vm.deal(initializer, 100 ether);

        dai = bridge.erc20token();
    }

    /*//////////////////////////////////////////////////////////////
                        UTILS
    //////////////////////////////////////////////////////////////*/

    function teleport(uint256 _timestamp) public {
        globalTime = _timestamp;
        vm.warp(globalTime);
    }

    function skipTime(uint256 secs) public {
        globalTime += secs;
        vm.warp(globalTime);
    }
}
