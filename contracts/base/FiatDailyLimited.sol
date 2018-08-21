//solium-disable linebreak-style
pragma solidity^0.4.24;

import "../PriceAggregator.sol";

/// @title Fiat Daily Limited - Based on DailyLimitModule.sol. This will allow to limit withdrawals of any asset based on a global daily limit set in USD (for instance). The amount withdrawn will depend on the USD value of each individual asset.
/// @author Paskal S
/// TODO: Implement changes to accomodate functionality. A list of supported assets is needed, the rest will require manual limits
contract FiatDailyLimited {

    // dailyLimits mapping maps token address to daily limit settings.
    mapping (address => DailyLimit) public dailyLimits;

    struct DailyLimit {
        uint256 dailyLimit;
        uint256 spentToday;
        uint256 lastDay;
    }

    /// @dev Setup function sets initial storage of contract.
    /// @param tokens List of token addresses. Ether is represented with address 0x0.
    /// @param _dailyLimits List of daily limits in smalles units (e.g. Wei for Ether).
    function setup(address[] tokens, uint256[] _dailyLimits)
        public
    {
        setManager();
        for (uint256 i = 0; i < tokens.length; i++)
            dailyLimits[tokens[i]].dailyLimit = _dailyLimits[i];
    }

    /// @dev Allows to update the daily limit for a specified token. This can only be done via a Safe transaction.
    /// @param token Token contract address.
    /// @param dailyLimit Daily limit in smallest token unit.
    function changeDailyLimit(address token, uint256 dailyLimit)
        public
        authorized
    {
        dailyLimits[token].dailyLimit = dailyLimit;
    }

    /// @dev Returns if Safe transaction is a valid daily limit transaction.
    /// @param token Address of the token that should be transfered (0 for Ether)
    /// @param to Address to which the tokens should be transfered
    /// @param amount Amount of tokens (or Ether) that should be transfered
    /// @return Returns if transaction can be executed.
    function executeDailyLimit(address token, address to, uint256 amount)
        public
    {
        // Only Safe owners are allowed to execute daily limit transactions.
        require(OwnerManager(manager).isOwner(msg.sender), "Method can only be called by an owner");
        require(to != 0, "Invalid to address provided");
        require(amount > 0, "Invalid amount provided");
        // Validate that transfer is not exceeding daily limit.
        require(isUnderLimit(token, amount), "Daily limit has been reached");
        dailyLimits[token].spentToday += amount;
        if (token == 0) {
            require(manager.execTransactionFromModule(to, amount, "", Enum.Operation.Call), "Could not execute ether transfer");
        } else {
            bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
            require(manager.execTransactionFromModule(token, 0, data, Enum.Operation.Call), "Could not execute token transfer");
        }
    }

    function isUnderLimit(address token, uint256 amount)
        internal
        returns (bool)
    {
        DailyLimit storage dailyLimit = dailyLimits[token];
        if (today() > dailyLimit.lastDay) {
            dailyLimit.lastDay = today();
            dailyLimit.spentToday = 0;
        }
        if (dailyLimit.spentToday + amount <= dailyLimit.dailyLimit && 
            dailyLimit.spentToday + amount > dailyLimit.spentToday)
            return true;
        return false;
    }

    /// @dev Returns last midnight as Unix timestamp.
    /// @return Unix timestamp.
    function today()
        public
        view
        returns (uint)
    {
        return now - (now % 1 days);
    }
}
