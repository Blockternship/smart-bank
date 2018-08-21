//solium-disable linebreak-style
pragma solidity^0.4.24;

import "./safe-contracts/contracts/OwnerManager.sol";
import "./RecoveryManager.sol";
import "./AccountManager.sol";

/// @title Bank Safe - Based on GnosisSafe.sol for the purpose of the smart bank. There's no need to manage modules
/// @author Paskal S
/// TODO: Modify existing contracts for the purpose of the smart bank
contract BankSafe is OwnerManager, RecoveryManager, AccountManager {

    //keccak256(
    //    "EIP712Domain(address verifyingContract)"
    //);
    bytes32 public constant DOMAIN_SEPERATOR_TYPEHASH = 0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;

    bytes32 public domainSeperator;

    /// @dev Setup function sets initial storage of contract.
    /// @param _owners List of Safe owners.
    /// @param _threshold Number of required confirmations for a Safe transaction.
    /// @param to Contract address for optional delegate call.
    /// @param data Data payload for optional delegate call.
    function setup(address[] _owners, uint _threshold, bytes32[] _accountNames)
        public
    {
        require(domainSeperator == 0, "Domain Seperator already set!");
        domainSeperator = keccak256(abi.encode(DOMAIN_SEPERATOR_TYPEHASH, this));
        setupOwners(_owners, _threshold);
        setupRecovery(_friends, _friendsThreshold);// Should be optional but highly encouraged. Do the setup somewhere else
        setupAccounts(_accountNames);
    }
}
