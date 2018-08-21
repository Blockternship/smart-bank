//solium-disable linebreak-style
pragma solidity^0.4.24;

import "./safe-contracts/contracts/SelfAuthorized.sol";

/// @title: Expiring - a contract base for contracts which expire (in one sense or another). The expiring modifier must be applied to any frunction that should reset the expiry of the contract
contract Expiring is SelfAuthorized {
    uint public expirationPeriod;
    uint public expirationTime;

    function setupExpiring(uint _expirationPeriod) internal {
        require(expirationTime != 0, "Expiration already set up!");
        expirationPeriod = _expirationPeriod;
        // solium-disable security/no-block-members
        expirationTime = now + expirationPeriod;
    }

    modifier expiring() {
        expirationTime = now + expirationPeriod;
        _;
    }

    function expired() public view returns(bool) {
        return now > expirationTime;
    }

    function resetExpiration() public authorized {
        expirationTime = now + expirationPeriod;
    }

    function setExpirationPeriod(uint _expirationPeriod) public authorized {
        // Limit the period between 1 hour and 10 years
        require(_expirationPeriod >= 1 hours && _expirationPeriod < 10 * 365 days, "Invalid expiration period!");
        expirationPeriod = _expirationPeriod;
        expirationTime = now + expirationPeriod;
    }
}