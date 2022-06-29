const token = artifacts.require("RewardToken");

module.exports = async function (deployer) {
    await deployer.deploy(token, "100000000000000000000");
    console.log('Token deployed at', token.address);
}