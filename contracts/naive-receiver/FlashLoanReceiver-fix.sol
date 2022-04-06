// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FlashLoanReceiverFix {
    using Address for address payable;

    address payable private pool;

    mapping(address => bool) public allowedAddress;

    constructor(address payable poolAddress) {
        pool = poolAddress;
        allowedAddress[msg.sender]= true;
    }

    // Function called by the pool during flash loan
    function receiveEther(uint256 fee) public payable {
        require(msg.sender == pool, "Sender must be pool");
        // Bug :- Here anybody can call the flashloan contract and drain all the eth from this contract as fees towards flashloan contract. 

        // Bug Fix : Only Allowed addresses can all the from the contract. 
        require(allowedAddress[tx.origin], "Only allowed addresses can call the flashloan");
        uint256 amountToBeRepaid = msg.value + fee;

        require(address(this).balance >= amountToBeRepaid, "Cannot borrow that much");
        
        _executeActionDuringFlashLoan();
        
        // Return funds to pool
        pool.sendValue(amountToBeRepaid);
    }

    // Internal function where the funds received are used
    function _executeActionDuringFlashLoan() internal { }

    // Allow deposits of ETH
    receive () external payable {}


}