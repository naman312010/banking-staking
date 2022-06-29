const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const token = artifacts.require("RewardToken");
const BankV1 = artifacts.require("BankV1");

module.exports = async function (deployer) {
    //params: [token_contract_address, time_period_in_seconds, total_reward_pool]
    const instance = await deployProxy(BankV1, [token.address, 7200, '10000000000000000000'], { deployer });
    tokenInstance = await token.deployed();
    await tokenInstance.transfer(instance.address,'10000000000000000000');
    console.log('Bank proxy deployed at', instance.address);
}