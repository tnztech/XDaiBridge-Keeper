source .env
forge script ./script/KeeperOperator.s.sol --rpc-url goerli --broadcast | grep '^TX_LOG'