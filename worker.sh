source .env
forge script ./script/KeeperOperator.s.sol --rpc-url mainnet --broadcast | grep '^TX_LOG'
