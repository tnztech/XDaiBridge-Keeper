// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IXDaiForeignBridge} from "./interfaces/IXDaiForeignBridge.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract BridgeKeeper {

    IXDaiForeignBridge public bridge = IXDaiForeignBridge(address(1));
    address public dai = bridge.erc20token();
    uint256 public refillThreshold = 100000 ether;
    uint256 public investThreshold = 1001000 ether;
    address public MANAGER;

    /**
    * @dev Throws if called by any account other than the manager.
    */
    modifier onlyManager() {
        require(msg.sender == MANAGER, "Not Manager");
        _;
    }

    constructor(address _manager) {
        MANAGER = _manager;
    }

    function claim() public {

        uint256 amount = bridge.interestAmount(dai);
        bridge.payInterest(dai, amount);

        uint256 balance = bridgeBalance();
        if(balance > investThreshold){
            bridge.investDai();
        }
        else if ( balance < refillThreshold){
            bridge.refillBridge();
        }
  
    }

    function bridgeBalance() public view returns(uint256 balance) {
        return IERC20(dai).balanceOf(address(bridge));
    }

    function claimable() public view returns(uint256) {
        return (bridge.interestAmount(dai) >= bridge.minInterestPaid(dai)) ? bridge.interestAmount(dai)  : 0;
    }

    function setRefillThreshold(uint256 _amount) external onlyManager{
        require(_amount < bridge.minCashThreshold(dai), "Higher than minCashThreshold");
        refillThreshold = _amount;
    }

    function setInvestThreshold(uint256 _amount) external onlyManager{
        require(_amount >= bridge.minCashThreshold(dai), "Lower than minCashThreshold");
        investThreshold = _amount;
    }

    function setNewManager(address _manager) external onlyManager{
        MANAGER = _manager;
    }

}
