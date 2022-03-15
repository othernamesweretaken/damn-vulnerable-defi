pragma solidity ^0.8.0;


import 'hardhat/console.sol';

contract attackerMulticall {
    struct Call3 {
        address target;
        bool allowedToBeFailed;
        bytes callData;
    }
    struct Result {
        bool success;
        bytes returnData;
    }
    // Picked from multicall 
    function tryAggregate(Call3[] calldata calls) public payable returns (Result[] memory returnData) {

        uint256 length = calls.length;
        returnData = new Result[](length);
        Call3 calldata _call;
        for (uint256 i = 0; i < length;) {
            Result memory result = returnData[i];
            _call = calls[i];
            (result.success, result.returnData) = _call.target.call(_call.callData);
            // If is allowed to failed - Don't stop even it is failed. 
            if (!_call.allowedToBeFailed) require(result.success, "Multicall3: call failed");
            unchecked { ++i; }
        }
    }
}