//solium-disable linebreak-style
pragma solidity 0.4.24;

/// @title Recovery Manager based on SocialRecoveryModule.sol. It is modified to fit the purpose of the Smart Bank. This will help manage the authorized recovery accounts
/// @author Paskal S
contract RecoveryManager {
    // TODO: consider implementing this exactly as the OwnerManager.sol, just with different variable names

    uint256 public recoveryThreshold;
    address[] public recoveryAccounts;

    // isRecoveryAccount mapping maps recovery account's address to recovery account status.
    mapping (address => bool) public isRecoveryAccount;
    // isExecuted mapping maps data hash to execution status.
    mapping (bytes32 => bool) public isExecuted;
    // isConfirmed mapping maps data hash to recovery account's address to confirmation status.
    mapping (bytes32 => mapping (address => bool)) public isConfirmed;

    modifier onlyRecoveryAccount() {
        require(isRecoveryAccount[msg.sender], "Method can only be called by a recovery account!");
        _;
    }

    /// @dev Setup function sets initial storage of contract.
    /// @param _recoveryAccounts List of recoveryAccounts' addresses.
    /// @param _threshold Required number of recoveryAccounts to confirm replacement.
    function setupRecovery(address[] _recoveryAccounts, uint256 _threshold)
        public
    {
        require(recoveryThreshold == 0, "Recovery already set up!");
        require(_threshold <= _recoveryAccounts.length, "Threshold cannot exceed recoveryAccounts count");
        require(_threshold >= 2, "At least 2 recoveryAccounts required");
        
        // Set allowed recoveryAccounts.
        for (uint256 i = 0; i < _recoveryAccounts.length; i++) {
            address recovery = _recoveryAccounts[i];
            require(recovery != 0, "Invalid recovery address provided!");
            require(!isRecoveryAccount[recovery], "Duplicate recovery address provided!");
            isRecoveryAccount[recovery] = true;
        }
        recoveryAccounts = _recoveryAccounts;
        recoveryThreshold = _threshold;
    }

    /// @dev Allows a recovery address to confirm a Safe transaction.
    /// @param dataHash Safe transaction hash.
    function confirmTransaction(bytes32 dataHash)
        public
        onlyRecoveryAccount
    {
        require(!isExecuted[dataHash], "Recovery already executed");
        isConfirmed[dataHash][msg.sender] = true;
    }

    /// To be implemented in a child contract
    // function recoverAccess() public onlyRecoveryAccount ;

    /// @dev Returns if Safe transaction is a valid owner replacement transaction.
    /// @param dataHash Data hash.
    /// @return Confirmation status.
    function isConfirmedByRequiredFriends(bytes32 dataHash)
        public
        view
        returns (bool)
    {
        uint256 confirmationCount;
        for (uint256 i = 0; i < recoveryAccounts.length; i++) {
            if (isConfirmed[dataHash][recoveryAccounts[i]])
                confirmationCount++;
            if (confirmationCount == recoveryThreshold)
                return true;
        }
        return false;
    }

    /// @dev Returns hash of data encoding owner replacement.
    /// @param data Data payload.
    /// @return Data hash.
    function getDataHash(bytes data)
        public
        pure
        returns (bytes32)
    {
        return keccak256(data);
    }
}
