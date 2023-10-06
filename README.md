## XDai Bridge Keeper

**This is a repo dedicated to maintenance of the XDai Bridge on Goerli and Mainnet**
**It has the ability to refill it, invest DAI into the sDAI vault, and to relay interest to Gnosis Chain**

## Usage

The Makefile has all the relevant commands

### Build

```shell
# Install Foundry
$ make install
# Update Foundry dependencies 
$ make update
# Run the maintenance scripts manually to make sure it's ready for setting up the automation
$ make run-keeper
# Setup the worker - pm2 can be monitored by calling "pm2 logs"
$ make automatic
```

### Docker 

- To run the keeper in docker container, follow the below steps!

- Create `.env`

- Start

```sh
docker compose up --build -d
```

- Logs

```sh
docker compose logs -f
```

- Stop

```sh
docker compose down
```

### Test

Use the goerli branch and test against the goerli bridge. Make sure that the cronjob is working by tracking the bridge address on goerli.etherscan.io. 

