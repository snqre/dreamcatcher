25.11.2023
The idea of the design was for the contract to be able to call itself to find its facet functions to share functionality. This design would limit attack vectors to external (only contract) functions which would only be called after a multi sig or referendum was passed.

Console > Diamond > Facet > Diamond > Facet

This method would not function properly with non reentrant mutex locks and therefore would pose a risk to the integrity of the mechanism. The alternative solution is now to place the shared logic within libraries which will be able to access shared (internal) storage within the Diamond.

This architecture requires modular storage contracts and facets.

FacetStorageA > FacetA
FacetStorageA > FacetB

^ In the above process libraries with shared logic would be used instead of calling functions internally. The storage is much safer when inherited internally rather than producing external calls.

As for design standards, any calls that involve external calls or recursive calls must have a nonReentrant modifier on them to avoid unexpected behaviour. The admin and role system will be found within the shared storage, and reusable business logic must all be written in libraries.

**Further vulnerabilities that require taking note of is the oracle. It does not register an average price over time, because the core concept is allow as many pairs to be tradeable from the start. Producing an average price oracle would require repeated calls in IUniswapV2 models. This has been fixed in UniswapV3, however, there is still a large amount of volume on V2, and it works out to be easier to start on V2. The idea of using chainlink or third party oracles rather than directly sourcing the price from the dexs did not suit the needs of the project. To protect users against oracle attacks, mapping as many dexs and pluggin them in to get a well rounded (weighted) average price can mitigate these situations. As the protocol is open and permissionless, clients and users must be aware that with the increased freedom, must come additional responsibility to make informed decisions. Vaults may choose to only trade high liquidity tokens and onboard a limited amount of value, this sort of information should reflect on the front-end.

NOTE Library structs can be directly used as storage for the Diamond and can be written with internal functions that can be shared accross the Diamond.

As of today, we will restructure the diamonds layout to ensure that these new findings are taken into account.

26.11.2023
Component > Slot [ must not clash ] > Contract

Chance of storage clash nearly impossible but not zero.