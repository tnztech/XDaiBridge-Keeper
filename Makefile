
# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

install	:; curl -L https://foundry.paradigm.xyz | bash && foundryup

update :; forge update

# Build & test
build  :; forge build --sizes

tests	:; forge test --fork-url goerli -vvv

run-keeper :; forge script script/KeeperOperator.s.sol --rpc-url goerli --broadcast

cronjob :; chmod +x runCronjob.sh setupCronjob.sh | ./setupCronjob.sh
