## XDai Bridge Keeper

**This is a repo dedicated to maintenance of the XDai Bridge on Goerli and Mainnet**
**It has the ability to refill it, invest DAI into the sDAI vault, and to relay interest to Gnosis Chain**

## Usage

The Makefile has all the relevant commands

It requires .env file which must be populated with the variables defined in the .env.example - 
Modify these variables at will.

If you plan to use the automated version: pm2_worker.json can be modified the cronrestart parameters with the interval you want to run the script. If you need help https://crontab.guru/


The Makefile has all the relevant commands

### Build

```shell
# Install Foundry
$ make install
# Update Foundry dependencies 
$ make update
# Run the maintenance scripts manually to make sure it's ready for setting up the automation
$ make run-keeper
# Run the maintenance scripts manually to make sure it's ready for setting up the automation
$ make worker-test
# Setup the worker - pm2 can be monitored by calling "pm2 logs"
$ make automated
# Kill the pm2 automated background process
$ make kill
# Clear all the worker logs from pm2 in the system
$ make clear-logs
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

