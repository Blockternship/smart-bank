# Safe Contracts - Repurposed

Most of the base contracts are repurposed from Gnosis' safe-contracts library. They had to be adapted as not all functionality will be needed, but more importantly the smart bank needs to have internal sub accounts from which every transfer needs to be executed, and to which every deposit needs to be handled.

Gnosis' safe contracts are all based on the proxy - master contract pattern, but this will be omitted for the initial implementation of the smart bank for simplicity. Future (closer to real products) implementation may consider this pattern as it will save A LOT of gas for new users (they won't have to deploy entire smart bank contracts, but just proxies which point to the master contract logic).

Original source: [https://github.com/gnosis/safe-contracts](https://github.com/gnosis/safe-contracts)