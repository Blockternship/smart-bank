//solium-disable linebreak-style
pragma solidity 0.4.24;

/// @title Recovery Manager based on SocialRecoveryModule.sol. It is modified to fit the purpose of the Smart Bank. This will help manage the authorized recovery accounts
/// @author Paskal S
/// TODO: Fix module manager problems
contract RecoveryManager {

    uint256 public recoveryThreshold;
    address[] public recoveryAccounts;

    // isRecoveryAccount mapping maps friend's address to friend status.
    mapping (address => bool) public isRecoveryAccount;
    // isExecuted mapping maps data hash to execution status.
    mapping (bytes32 => bool) public isExecuted;
    // isConfirmed mapping maps data hash to friend's address to confirmation status.
    mapping (bytes32 => mapping (address => bool)) public isConfirmed;

    modifier onlyFriend() {
        require(isRecoveryAccount[msg.sender], "Method can only be called by a friend");
        _;
    }

    /// @dev Setup function sets initial storage of contract.
    /// @param _friends List of recoveryAccounts' addresses.
    /// @param _threshold Required number of recoveryAccounts to confirm replacement.
    function setup(address[] _friends, uint256 _threshold)
        public
    {
        require(_threshold <= _friends.length, "Threshold cannot exceed recoveryAccounts count");
        require(_threshold >= 2, "At least 2 recoveryAccounts required");
        
        // Set allowed recoveryAccounts.
        for (uint256 i = 0; i < _friends.length; i++) {
            address friend = _friends[i];
            require(friend != 0, "Invalid friend address provided");
            require(!isRecoveryAccount[friend], "Duplicate friend address provided");
            isRecoveryAccount[friend] = true;
        }
        recoveryAccounts = _friends;
        recoveryThreshold = _threshold;
    }

    /// @dev Allows a friend to confirm a Safe transaction.
    /// @param dataHash Safe transaction hash.
    function confirmTransaction(bytes32 dataHash)
        public
        onlyFriend
    {
        require(!isExecuted[dataHash], "Recovery already executed");
        isConfirmed[dataHash][msg.sender] = true;
    }

    /// @dev Returns if Safe transaction is a valid owner replacement transaction.
    /// @param prevOwner Owner that pointed to the owner to be replaced in the linked list
    /// @param oldOwner Owner address to be replaced.
    /// @param newOwner New owner address.
    /// @return Returns if transaction can be executed.
    function recoverAccess(address prevOwner, address oldOwner, address newOwner)
        public
        onlyFriend
    {
        bytes memory data = abi.encodeWithSignature("swapOwner(address,address,address)", prevOwner, oldOwner, newOwner);
        bytes32 dataHash = getDataHash(data);
        require(!isExecuted[dataHash], "Recovery already executed");
        require(isConfirmedByRequiredFriends(dataHash), "Recovery has not enough confirmations");
        isExecuted[dataHash] = true;
        require(manager.execTransactionFromModule(address(manager), 0, data, Enum.Operation.Call), "Could not execute recovery");
    }

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
