//solium-disable linebreak-style
pragma solidity^0.4.24;

import "./lib/auth.sol";

/// @title: Price Aggregator - this contract collects on-chain price data from trusted sources (DEXs or price feeds) for different assets
contract PriceAggregator is DSAuth {

    mapping (address => bool) public assetSupported;

    /// TODO: Add USD price feed - use the Dai price feed 0x729D19f657BD0614b4985Cf1D82531c67569197B
    ///       Add a way to add DEXs, average a token's price in ETH among a few sources and return it in USD

    function getPrice(address asset) public view returns(uint usdPriceWad, bool valid);

}