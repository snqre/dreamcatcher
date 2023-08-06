

HUB
ROUTER
IMPLEMENTATION

MIRAI
DREAMCATCHER


# Log Standards
> Ensuring accurate logging of all our contracts is of paramount importance for promoting transparency, especially considering the intricate interactions among various contracts within our system. To uphold this principle, we have meticulously devised standardized protocols for recording data when deploying a new module and interfacing with the corresponding eternal storage in Storage.sol.

> These well-defined standards serve as a comprehensive guide for other contracts within our ecosystem, elucidating the expected data structure and communication protocols when accessing eternal storages. By adhering to these established norms, our contracts can seamlessly interact with one another, fostering a harmonious and transparent operational environment.

<TAG> <MODULE ITERATION> <CLASS> <ECOSYSTEM> <CHAIN> <STATE> <ADDRESS>        
*   TAG: A unique tag given to the storage.
*   MODULE: A descriptive name of what it does ie. KEY or TOKEN.
*   ITERATION: If it is not the first storage for this module the log the number.
*   CLASS: A tag given so other contracts know what to expect when requesting data from the storage.
*   ECOSYSTEM: What is the core ecosystem of the storage ie. MIRAI.
*   CHAIN: The blockchain it is located on.
*   STATE: TESTNET or MAINNET.
*   ADDRESS: Where it is deployed.

# Log



# Log Testnet Polygon
M81     HUB000      HUB     DREAMCATCHER     POLYGON    TESTNET     ADDRESS