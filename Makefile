
# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

install	:; curl -L https://foundry.paradigm.xyz | bash && foundryup | npm install -g pm2

update :; forge update

# Build & test
build  :; forge build --sizes

tests	:; forge test --fork-url mainnet -vvv

run-keeper :; forge script script/KeeperOperator.s.sol --rpc-url mainnet --broadcast

automatic :; pm2 start pm2_worker.json

clear-logs :; pm2 flush Keeper
