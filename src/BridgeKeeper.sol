// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {IXDaiForeignBridge} from "./interfaces/IXDaiForeignBridge.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract BridgeKeeper {
    IXDaiForeignBridge public bridge =
        IXDaiForeignBridge(0x8659Cf2273438f9b5C1Eb367Def45007a7A16a24);
    address public dai = 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;
    uint256 public refillThreshold = 10 ether;
    uint256 public investThreshold = 110 ether;
    address public MANAGER;

    constructor(address _manager) {
        MANAGER = _manager;
    }

    /**
     * @dev Throws if called by any account other than the manager.
     */
    modifier onlyManager() {
        require(msg.sender == MANAGER, "Not Manager");
        _;
    }

    function claim() public {
        uint256 amount = bridge.interestAmount(dai);
        uint256 balance = bridgeBalance();

        bridge.payInterest(dai, amount);

        if (balance > investThreshold) {
            bridge.investDai();
        } else if (balance < refillThreshold) {
            bridge.refillBridge();
        }
    }

    function bridgeBalance() public view returns (uint256 balance) {
        return IERC20(dai).balanceOf(address(bridge));
    }

    function claimable() public view returns (uint256) {
        return
            (bridge.interestAmount(dai) >= bridge.minInterestPaid(dai))
                ? bridge.interestAmount(dai)
                : 0;
    }

    function setRefillThreshold(uint256 _amount) external onlyManager {
        require(
            _amount < bridge.minCashThreshold(dai),
            "Higher than minCashThreshold"
        );
        refillThreshold = _amount;
    }

    function setInvestThreshold(uint256 _amount) external onlyManager {
        require(
            _amount >= bridge.minCashThreshold(dai),
            "Lower than minCashThreshold"
        );
        investThreshold = _amount;
    }

    function setNewManager(address _manager) external onlyManager {
        MANAGER = _manager;
    }
}
