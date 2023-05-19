# SingleState

The SingleState is designed to be allow anyone to create a Pool without having to deploy multiple smart contracts (which can be expensive). There is the choice of deploying with an external ERC20 contract for their Pool, but we can allow anyone to create a Pool without needing to deploy any smart contract, significantly reducing the cost of setting up a Pool.

The SingleState as the name implied stores all state variables and data onto one shared smart contract. Funds are also stored within the same smart contract, thorough accounting is done to make sure assets and funds are not mixed up.

It is by far the cheapest product we have to offer, and allows anyone to participate.