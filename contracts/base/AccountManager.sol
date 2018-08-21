//solium-disable linebreak-style
pragma solidity^0.4.24;

import "./safe-contracts/contracts/SelfAuthorized.sol";
import "../accounting/contracts/Accounting.sol";

/// @title: Account Manager - allows for internal handling of multiple accounts which can all hold Ether and ERC20 tokens
/// @author: Paskal S
contract AccountManager is Accounting, SelfAuthorized {

    // Using the linked list pattern as used by the Gnosis safe contracts. The keys (names of the Accounts) are bytes32 and the actual acccounts are in a separate mapping
    bytes32 public constant SENTINEL_ACCOUNTS = bytes32(-1);

    mapping(bytes32 => bytes32) internal accountNames;
    mapping(bytes32 => Account) internal accounts;
    // we need to track balances (of tokens and ETH) because an account can only be removed if it is empty 
    mapping(bytes32 => uint) internal cumulativeBalances;
    uint256 numberOfAccounts;// this will be the number of accounts in addition to the fallback "base" account

    /// Override default accounting functions to also include the cumulative balances tracking per account
    /// Tokens and ETH are all added together since we're only interested in whether there is any balance or not

    function depositETH(Account storage a, address _from, uint _value) internal {
        super.depositETH(a, _from, _value);
        cumulativeBalances[a.name] += _value;
    }

    function depositToken(Account storage a, address _token, address _from, uint _value) internal {
        super.depositToken(a, _token, _from, _value);
        cumulativeBalances[a.name] += _value;
    }

    function sendETH(Account storage a, address _to, uint _value) internal {
        super.sendETH(a, _to, _value);
        cumulativeBalances[a.name] -= _value;
    }

    function transact(Account storage a, address _to, uint _value, bytes data) internal {
        super.transact(a, _to, _value, data);
        cumulativeBalances[a.name] -= _value;
    }

    function sendToken(Account storage a, address _token, address _to, uint _value) internal {
        super.sendToken(a, _token, _to, _value);
        cumulativeBalances[a.name] -= _value;
    }

    function transferETH(Account storage _from, Account storage _to, uint _value) internal { 
        super.transferETH(_from, _to, _value);
        cumulativeBalances[_from.name] -= _value;
        cumulativeBalances[_to.name] += _value;
    }

    function transferToken(Account storage _from, Account storage _to, address _token, uint _value) internal { 
        super.transferToken(_from, _to, _token, _value);
        cumulativeBalances[_from.name] -= _value;
        cumulativeBalances[_to.name] += _value;
    }

    function balanceToken(Account storage toAccount, address _token, uint _value) internal {
        super.balanceToken(toAccount, _token, _value);
        cumulativeBalances[toAccount.name] += _value;
    }

    /// Set up accounts using an array of account names. Can only be done once.
    function setupAccounts(bytes32[] _names)
        internal
    {        
        bytes32 currentAccountName = SENTINEL_ACCOUNTS;
        require(accountNames[SENTINEL_ACCOUNTS] == 0, "Accounts already set up!");
        for (uint256 i = 0; i < _names.length; i++) {
            
            bytes32 _name = _names[i];
            require(_name != 0 && _name != SENTINEL_ACCOUNTS, "Invalid account name provided!");
            // No duplicate accounts allowed.
            require(accountNames[_name] == 0, "Duplicate account name provided!");
            accountNames[currentAccountName] = _name;
            accounts[_name] = Account({name: _name, balanceETH: 0});
            currentAccountName = _name;
        }
        accountNames[currentAccountName] = SENTINEL_ACCOUNTS;
        numberOfAccounts = _names.length;
    }

    /// Add an account using a name
    function addAccount(bytes32 _name)
        public
        authorized
    {
        // Owner address cannot be null.
        require(_name != 0 && _name != SENTINEL_ACCOUNTS, "Invalid account name provided!");
        // No duplicate owners allowed.
        require(accountNames[_name] == 0, "Account with the same name already exists!");
        accountNames[_name] = accountNames[SENTINEL_ACCOUNTS];
        accountNames[SENTINEL_ACCOUNTS] = _name;
        accounts[_name] = Account({name: _name, balanceETH: 0});
        numberOfAccounts++;
    }

    /// Remove an account from the linked list by specifying the previous account name in the list and the account to remove
    function removeAccount(bytes32 prevAccountName, bytes32 _name)
        public
        authorized
    {
        require(cumulativeBalances[_name] == 0, "Account is not empty!");
        require(numberOfAccounts >= 1, "No accounts to remove!");
        require(_name != 0 && _name != SENTINEL_ACCOUNTS, "Invalid owner address provided");
        require(accountNames[prevAccountName] == _name, "Invalid prevAccountName/_name pair provided");
        accountNames[prevAccountName] = accountNames[_name];
        accountNames[_name] = 0;
        accounts[_name] = Account({name: 0, balanceETH: 0});
        numberOfAccounts--;
    }

    /// Check whether an account with the given name exists
    function accountExists (bytes32 _name)
        public
        view
        returns (bool)
    {
        return accountNames[_name] != 0;
    }

    /// Get all account names as an array
    function getAccountNames()
        public
        view
        returns (bytes32[])
    {
        bytes32[] memory array = new bytes32[](numberOfAccounts);

        // populate return array
        uint256 index = 0;
        bytes32 currentAccountName = accountNames[SENTINEL_ACCOUNTS];
        while(currentAccountName != SENTINEL_ACCOUNTS) {
            array[index] = currentAccountName;
            currentAccountName = accountNames[currentAccountName];
            index ++;
        }
        return array;
    }
}
