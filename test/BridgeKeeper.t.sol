// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/BridgeKeeper.sol";
import "./Setup.t.sol";

contract BridgeKeeperTest is SetupTest {

    event UserRequestForAffirmation(address recipient, uint256 value);

    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testMetadata() external {
        assertEq(keeper.dai() ,bridge.erc20token());
        assertEq(address(keeper.bridge()) , address(bridge));
        assertEq(keeper.MANAGER(), manager);
    }

    function claimable() public view returns(uint256){
        return keeper.claimable();
    }

    function bridgeBalance() public view returns(uint256){
        return keeper.bridgeBalance();
    }



    /*//////////////////////////////////////////////////////////////
                        CONFIG FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testSetRefillThreshold(uint256 amount) external {
        vm.startPrank(manager);
         if (amount > bridge.minCashThreshold(dai)){
        vm.expectRevert("Higher than minCashThreshold");
        keeper.setRefillThreshold(amount);
        } else {
            keeper.setRefillThreshold(amount);
            assertEq(keeper.refillThreshold(), amount);
        }
        vm.stopPrank();
    }

    function testSetInvestThreshold(uint256 amount) external {
        vm.startPrank(manager);
        if (amount < bridge.minCashThreshold(dai)){
            vm.expectRevert("Lower than minCashThreshold");
            keeper.setInvestThreshold(amount);
        }
        else {
            keeper.setInvestThreshold(amount);
            assertEq(keeper.investThreshold(), amount);
        }
        vm.stopPrank();
    }

    function testSetNewManager() external {
        vm.startPrank(manager);
        keeper.setNewManager(address(20));
        assertEq(keeper.MANAGER() , address(20));
        vm.stopPrank();
        vm.expectRevert("Not Manager");
        keeper.setNewManager(address(5));
        vm.startPrank(address(20));
        keeper.setNewManager(manager);
        assertEq(keeper.MANAGER() , manager);
        vm.stopPrank();
    }


    /*//////////////////////////////////////////////////////////////
                        CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testClaim() external {
        uint256 balance = bridgeBalance();
        uint256 interest = claimable();
        uint256 invested = bridge.investedAmount(dai);

        if (interest > 0){
        if (balance < keeper.refillThreshold()){
            vm.expectEmit();
            emit UserRequestForAffirmation(bridge.interestReceiver(dai), interest);
            keeper.claim();

            assertEq(bridgeBalance(), bridge.minCashThreshold(dai));
            assertEq(claimable(), 0);

        }

        else if (balance > keeper.investThreshold()){
            vm.expectEmit();
            emit UserRequestForAffirmation(bridge.interestReceiver(dai), interest);
            keeper.claim();

            assertLt(bridgeBalance(), balance);
            assertEq(claimable(), 0);
            assertGt(bridge.investedAmount(dai), invested );
            assertEq(balance - bridgeBalance(), bridge.investedAmount(dai) - invested + claimable());
        }
        else{
            vm.expectEmit();
            emit UserRequestForAffirmation(bridge.interestReceiver(dai), interest);
            keeper.claim();

            assertEq(claimable(), 0);
            assertGt(bridge.investedAmount(dai), invested);
            assertEq(bridge.investedAmount(dai), invested + interest );
            assertEq(bridgeBalance(), balance);
        }
        }
        else{
            vm.expectRevert("Collectable interest too low");
            keeper.claim();
            assertEq(interest, claimable());
        }


    }


}
