//solium-disable linebreak-style
pragma solidity^0.4.24;

import "./safe-contracts/contracts/SelfAuthorized.sol";
import "../accounting/contracts/Accounting.sol";

/// @title: Account Manager - allows for internal handling of multiple accounts which can all hold Ether and ERC20 tokens
/// @author: Paskal S
contract AccountManager is Accounting, SelfAuthorized {

    // Using the linked list pattern as used by the Gnosis safe contracts. The keys are bytes32 and the actual acccounts are in a separate mapping
    bytes32 public constant SENTINEL_ACCOUNTS = bytes32(-1);

    mapping(bytes32 => bytes32) internal accountNames;
    mapping(bytes32 => Account) internal accounts;
    // we need to track balances (of tokens and ETH) because an account can only be removed if it is empty 
    mapping(bytes32 => uint) internal cumulativeBalances;
    uint256 numberOfAccounts;// this will be the number of accounts in addition to the fallback "base" account

    function setupAccounts(bytes32[] _names)
        internal
    {        
        bytes32 currentAccountName = SENTINEL_ACCOUNTS;
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

    function accountExists (bytes32 _name)
        public
        view
        returns (bool)
    {
        return accountNames[_name] != 0;
    }

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
