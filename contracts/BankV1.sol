// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BankV1 is Initializable {
    
    ERC20 rewardToken;
    uint256 public timePeriod;
    uint256 public startTime;
    uint256 stakingPool;
    uint256 stakers;
    address owner;
    uint256 r1;
    uint256 r2;
    uint256 r3;

    mapping(address => uint256) public stakedAmount;

    event Deposited(address indexed user, uint256 indexed amount);
    event Redeemed(address indexed user, uint256 indexed amount);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //rewardContract: the ERC20 contract whose tokens are used for the reward pool
    //T: Time period in seconds
    //rewardPoolSize: the reward pool for staking rewards
    function initialize(
        address rewardContract,
        uint256 T,
        uint256 rewardPoolSize
    ) external initializer {
        rewardToken = ERC20(rewardContract);
        startTime = block.timestamp;
        timePeriod = T;
        r1 = rewardPoolSize / 5;
        r2 = (rewardPoolSize * 3) / 100;
        r3 = rewardPoolSize / 2;
        stakingPool = 0;
        stakers = 0;
        owner = msg.sender;
    }

    function deposit(uint256 amount) external returns (bool) {
        require(
            block.timestamp <= (startTime + timePeriod),
            "Staking time has elapsed"
        );
        require(
            rewardToken.balanceOf(msg.sender) >= amount,
            "Not enough reward token balance"
        );
        require(rewardToken.allowance(msg.sender, address(this)) >= amount,"Funds not approved");
        bool transferred = rewardToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (stakedAmount[msg.sender] == 0) {
            stakers++;
        }
        stakedAmount[msg.sender] += amount;
        stakingPool += amount;
        emit Deposited(msg.sender, amount);
        return (transferred);
    }

    function calculateReward(address staker) internal returns (uint256) {
        uint256 reward;
        uint256 availableRewardPool;
        if (
            block.timestamp > (startTime + 2 * timePeriod) &&
            block.timestamp <= (startTime + 3 * timePeriod)
        ) {
            availableRewardPool = r1;
            reward =
                (stakedAmount[staker] * availableRewardPool) /
                stakingPool;
            r1 -= reward;
        } else if (
            block.timestamp > (startTime + 3 * timePeriod) &&
            block.timestamp <= (startTime + 4 * timePeriod)
        ) {
            availableRewardPool = r1 + r2;
            reward =
                (stakedAmount[staker] * availableRewardPool) /
                stakingPool;
            if (reward <= r1) r1 -= reward;
            else if (r1 == 0) r2 -= reward;
            else {
                r2 -= (reward-r1);
                r1 = 0;
            }
        } else {
            availableRewardPool = r1 + r2 + r3;
            reward =
                (stakedAmount[staker] * availableRewardPool) /
                stakingPool;
            if (reward <= r1) r1 -= reward;
            else if (r1 == 0 && r2 == 0) r3 -= reward;
            else if (reward <= (r1+r2)){
                r2 -= (reward-r1);
                r1 = 0;
            }
            else {
                r3 -= (reward - r1 - r2);
                r2 = 0;
                r3 = 0;
            }
        }
        return (reward);
    }

    function withdraw() external returns (bool) {
        require(
            stakers > 0 && stakedAmount[msg.sender] > 0 && stakingPool > 0,
            "No stakers"
        );
        require(
            stakedAmount[msg.sender] > 0 && stakingPool > 0,
            "No staked tokens"
        );
        require(
            block.timestamp > (startTime + timePeriod),
            "Waiting period is yet to pass"
        );
        uint256 amount = 0;
        amount += stakedAmount[msg.sender];
        uint256 reward = calculateReward(msg.sender);
        stakedAmount[msg.sender] = 0;
        stakers--;
        stakingPool -= amount;
        bool transferred = rewardToken.transfer(msg.sender, amount + reward);
        emit Redeemed(msg.sender,amount + reward);
        return (transferred);
    }

    function withdrawRemaining() external onlyOwner {
        require(stakingPool == 0 && stakers == 0, "Staked tokens remain");
        require(block.timestamp < (startTime + 4 * timePeriod),"Claim time window has passed");
        rewardToken.transfer(owner, r1+r2+r3);
        r1 = 0;
        r2 = 0;
        r3 = 0;
    } 

    fallback() external {}

    receive() external payable {}
}
