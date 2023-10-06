
# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

install	:; curl -L https://foundry.paradigm.xyz | bash && foundryup | npm install -g pm2

update :; forge update

# Build & test
build  :; forge build --sizes

tests	:; forge test --fork-url goerli -vvv

run-keeper :; forge script script/KeeperOperator.s.sol --rpc-url goerli --broadcast

run-keeper-simple :; forge script script/KeeperOperator.s.sol --rpc-url goerli --broadcast | grep '^TX_LOG'

worker-test :; bash ./worker.sh

automated :; pm2 start pm2_worker.json

kill :; pm2 kill

clear-logs :; pm2 flush Keeper
