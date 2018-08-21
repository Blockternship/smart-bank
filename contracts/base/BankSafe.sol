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
    function setup(address[] _owners, uint256 _threshold, address to, bytes data)
        public
    {
        require(domainSeperator == 0, "Domain Seperator already set!");
        domainSeperator = keccak256(abi.encode(DOMAIN_SEPERATOR_TYPEHASH, this));
        setupOwners(_owners, _threshold);
        // As setupOwners can only be called if the contract has not been initialized we don't need a check for setupModules
        setupModules(to, data);
    }
}
