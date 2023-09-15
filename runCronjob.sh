#!/bin/bash
cd /home/luigy/Programming/gnosis/xdaibridge-keeper
source /home/luigy/Programming/gnosis/xdaibridge-keeper/.env
forge script script/KeeperOperator.s.sol --rpc-url mainnet --broadcast --silent