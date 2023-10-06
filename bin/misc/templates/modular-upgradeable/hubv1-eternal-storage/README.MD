

HUB
ROUTER
IMPLEMENTATION

MIRAI
DREAMCATCHER


# Log Standards
> Ensuring accurate logging of all our contracts is of paramount importance for promoting transparency, especially considering the intricate interactions among various contracts within our system. To uphold this principle, we have meticulously devised standardized protocols for recording data when deploying a new module and interfacing with the corresponding eternal storage in Storage.sol.

> These well-defined standards serve as a comprehensive guide for other contracts within our ecosystem, elucidating the expected data structure and communication protocols when accessing eternal storages. By adhering to these established norms, our contracts can seamlessly interact with one another, fostering a harmonious and transparent operational environment.

When creating new storage its important to set the bytes array .properties to the following arguments

TAG, CLASS, ECOSYSTEM, CHAIN, STATE, ADDRESS

You can access these properties from every compliant Storage contract by using: 

    getBytes(0x2e70726f70657274696573);
    
    The value to pass is ".properties" -> bytes32
    
    This will return bytes which can be decoded to get the above arguments.

## Example
> M81 89 HUB DREAMCATCHER POLYGON TESTNET 0xd9145CCE52D386f254917e481eB44e9943F39138

> I3K 12 ROUTER MIRAI POLYGON MAINNET 0xd9145CCE52D386f254917e481eB44e9943F39138

<TAG> <MODULE ITERATION> <CLASS> <ECOSYSTEM> <CHAIN> <STATE> <ADDRESS>        
*   TAG: A unique tag given to the storage.
*   MODULE: A descriptive name of what it does ie. KEY or TOKEN.
*   CLASS: A tag given so other contracts know what to expect when requesting data from the storage.
*   ECOSYSTEM: What is the core ecosystem of the storage ie. MIRAI.
*   CHAIN: The blockchain it is located on.
*   STATE: TESTNET or MAINNET.
*   ADDRESS: Where it is deployed.

We document all of this in accessible documents
these are also callable within our storage contracts
# Log



# Log Testnet Polygon
M81     HUB000      HUB     DREAMCATCHER     POLYGON    TESTNET     ADDRESS