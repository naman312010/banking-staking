var token = artifacts.require("RewardToken");

module.exports = function (deployer) {
    deployer.deploy(token, "100000000000000000000");
    console.log('Token deployed at', token.address);
}