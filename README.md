# banking-staking
A simple Dapp that demonstrates banking and staking using on-chain ERC-20 tokens. Supports openzeppelin/truffle-upgrades library

## Deployed contacts
RewardToken: https://rinkeby.etherscan.io/address/0xf305E044011850bf58101d432040D99a75afa7e7#code
BankV1 proxy: https://rinkeby.etherscan.io/address/0x752B3534c3B0Dbcd344A4e3C99EAaCA9b1D6D185#code

## Get started:
1. Run 'git clone https://github.com/naman312010/banking-staking.git'
2. Navigate to 'banking-staking' folder
3. Run 'npm install'

## Run pre-written tests on Truffle's local development network:
1. Finish up the 'Getting started' section or skip if already done
2. Navigate to 'banking-staking' directory
3. Run 'truffle develop' to initiate the local network
4. In the network console, run 'test'

## Deploy to Rinkeby network
1. Finish up the 'Getting started' section or skip if already done
2. Navigate to 'banking-staking' directory
3. Create a '.env' file in  directory and define: <br>
- 'mnemonic': 12-word mnemonic to grant access to Truffle to deploy on the account's behalf
- 'provider': HTTP link for Truffle to communicate with to access public blockchain nodes You will need enough bandwidth available with the provider to a lot of requests in a short amount of time)
4.  In case you wish to change preset deployment parameters, open './migrations/2_deploy_token.js' and/or './migrations/3_deploy_BankV1.js' and change as desired.
5. Run 'truffle migrate --network rinkeby'
6. Do note the various addresses, since this is an openzeppelin/truffle-upgrades enabled project and you will have to interact with the proxy contract instead of main bank implementation on EtherScan

## Verify smart contracts on Rinkeby EtherScan
1. Finish up 'Deploy to Rinkeby network'
2. Open the '.env' file and add a valid 'ETHERSCAN_KEY' for verifying smart contracts
3. Run 'truffle run verify RewardToken BankV1 --network rinkeby'
4. Note the addresses listed for each in order to interact with them on Rinkeby Etherscan

## Working Flow
1. Upon deployment by scripts, the deploying account becomes owner of the bank and the bank already has the pre-defined starting funds
2. The deploying account also has almost all of the initial supply of the ERC20 token
3. A user would first need to call 'approve' in the token contract and approve the bank ('s proxy address) to use/transfer the amount of funds they wish to deposit
4. The user would then call 'deposit' function of the Bank smart contract to deposit allowed amount
5. The user can withdraw funds any time after (starting_time + 2*time_period), and get better rewards the longer they wait
6. If all staked users have withdrawn their stakes before (starting_time + 4*time_period) passes, the bank owner can withdraw the rest