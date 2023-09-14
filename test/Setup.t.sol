// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";
import "../src/BridgeKeeper.sol";
import "../src/interfaces/IXDaiForeignBridge.sol";



contract SetupTest is Test {

    address public initializer = address(17);
    address public manager = address(18);
    address public dai;
    address public bridgeAddress = 0x8659Cf2273438f9b5C1Eb367Def45007a7A16a24;
    IXDaiForeignBridge public bridge;
    BridgeKeeper keeper; 
    uint256 public globalTime;

    function setUp() public payable {

        console.log("chainId %s",block.chainid);
        console.log("block %s",block.number);

        bridge = IXDaiForeignBridge(bridgeAddress);

        globalTime = block.timestamp;

        vm.deal(initializer, 100 ether);
        vm.deal(manager, 10000 ether);

        /*//////////////////////////////////////////////////////////////
                                DEPLOYMENTS
        //////////////////////////////////////////////////////////////*/
        vm.prank(initializer);
        keeper = new BridgeKeeper(manager);
        dai = keeper.dai();
    }

    /*//////////////////////////////////////////////////////////////
                        UTILS
    //////////////////////////////////////////////////////////////*/

    function teleport(uint256 _timestamp) public{
        globalTime = _timestamp;
        vm.warp(globalTime);
    }

    function skipTime(uint256 secs) public{
        globalTime += secs;
        vm.warp(globalTime);
    }
}