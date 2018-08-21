// solium-disable linebreak-style
pragma solidity^0.4.24;

import "./base/BankSafe.sol";
import "./base/FiatDailyLimited.sol";
import "./base/safe-contracts/contracts/SignatureValidator.sol";

contract SmartBank is BankSafe, SignatureValidator, FiatDailyLimited {
    //TODO: Define code, reuse some basic functionality from Gnosis' safe-contracts

    

}