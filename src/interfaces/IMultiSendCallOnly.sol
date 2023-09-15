pragma solidity ^0.8.10;

interface IMultiSendCallOnly {
    function multiSend(bytes memory transactions) external payable;
}
