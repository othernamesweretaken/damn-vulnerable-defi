// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPoolFix {
    using Address for address payable;

    mapping (address => uint256) private balances;
    // Note: We ensure deposit and withdraw are not called during flashloan. We wrap the flashloan in a modifier. 
    
    bool private isFlashLoan;
    modifier onlyFlashLoan() {
        isFlashLoan = true;
        _;
        isFlashLoan = false;
    }

    modifier flashLoanNonReEntrant() {
        require(!isFlashLoan, "Cannot deposit during flashLoan");
        _;
    }
    function deposit() flashLoanNonReEntrant external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() flashLoanNonReEntrant external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) onlyFlashLoan external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}
 