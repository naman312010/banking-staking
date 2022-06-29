const chai = require('chai');
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const { time } = require("@openzeppelin/test-helpers");

// Load compiled artifacts
const Bank = artifacts.require('BankV1');
const Token = artifacts.require('RewardToken');

// Start test block
contract('BankV1', async function (accounts) {
  // Test case
  it('Bank has correct amount of reward tokens', async function () {
    const tokenInstance = await Token.deployed()
    expect((await tokenInstance.balanceOf.call(Bank.address)).toString()).to.equal("10000000000000000000");
  });

  it('Deployer has remaining tokens', async function () {
    const tokenInstance = await Token.deployed()
    expect((await tokenInstance.balanceOf.call(accounts[0])).toString()).to.equal('90000000000000000000');
  });

  it('Sent 10 RWT to a second address', async function () {
    const tokenInstance = await Token.deployed();
    await tokenInstance.transfer(accounts[1], '10000000000000000000');
    expect((await tokenInstance.balanceOf.call(accounts[0])).toString()).to.equal('80000000000000000000');
  });

  it('Second account has 10 RWT', async function () {
    const tokenInstance = await Token.deployed();
    expect((await tokenInstance.balanceOf.call(accounts[1])).toString()).to.equal('10000000000000000000');
  });

  it('First account can deposit 1 RWT', async function () {
    const tokenInstance = await Token.deployed();
    const bank = await Bank.deployed()
    await tokenInstance.approve(bank.address, '1000000000000000000');
    await bank.deposit('1000000000000000000');
    expect((await tokenInstance.balanceOf.call(bank.address)).toString()).to.equal('11000000000000000000');
  });

  it('Second account can deposit 2 RWT', async function () {
    const tokenInstance = await Token.deployed();
    const bank = await Bank.deployed()
    await tokenInstance.approve(bank.address, '2000000000000000000',{from:accounts[1]});
    await bank.deposit('2000000000000000000',{from:accounts[1]});
    expect((await tokenInstance.balanceOf.call(bank.address)).toString()).to.equal('13000000000000000000');
  });

  it("First account withdraws between (2*time_period) and (3*time_period)", async () => {
    const tokenInstance = await Token.deployed();
    const bank = await Bank.deployed();
    const tp = await bank.timePeriod.call();
    const start = await bank.startTime.call();
    let duration = time.duration.seconds(tp*2+1);
    await time.increase(duration);
    await bank.withdraw({from:accounts[0]});
    expect(Number(await tokenInstance.balanceOf.call(accounts[0]))).to.above(Number('80000000000000000000'));
  });

  it("Second account withdraws between (3*time_period) and (4*time_period)", async () => {
    const tokenInstance = await Token.deployed();
    const bank = await Bank.deployed();
    const tp = await bank.timePeriod.call();
    const start = await bank.startTime.call();
    let duration = time.duration.seconds(tp);
    await time.increase(duration);
    await bank.withdraw({from:accounts[1]});
    expect(Number(await tokenInstance.balanceOf.call(accounts[1]))).to.above(Number('10000000000000000000'));
  });

  it("Bank owner account withdraws all remaining tokens before (4*time_period)", async () => {
    const tokenInstance = await Token.deployed();
    const bank = await Bank.deployed();
    await bank.withdrawRemaining({from:accounts[0]});
    expect(Number(web3.utils.fromWei(await tokenInstance.balanceOf.call(accounts[0])))).to.above(Number(web3.utils.fromWei('80600000000000000000')));
  });
});
