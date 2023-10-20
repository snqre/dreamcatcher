# Structure of Storage Slot Declaration

1. function example() public view virtual returns (datatype)
2. perform action? public virtual
3. function ____example() internal pure virtual returns (bytes32)
4. function _setExample(args) internal virtual

---

Unlike normal solidity code variables must be declared in this fashion. This is to allow cross compatibility through out all contracts and avoid storage vulnerabilities.

There must be no constructors on implementations or proxy contracts.

Remember that once configured the proxy cannot be configured again and once initialized the implementation cannot do so again. If the new implementation after an upgrade required new initialization its best to create a set up function to do so. It's typically better to inherit the previous implementation that to build a new one from scratch as that leaves room for error, incompatibility or storage vulnerabilities.

Make sure that each unique variable has a key ____thisIsAKey() that returns the bytes32 location in storage.

---

By using this standard we are able to produce upgrades and easily swap functionalities, as the proxy simply acts as a storage.

WARNING: If the upgrade function is missing on the implementation the proxy will forever be immutable. This is done as not every implementation should be upgradeable, when we want multi contracts to point to the same implementation but dont want that to be upgradeable this is a good solution.

---

In v1.0.0 we recognize that gas costs, and efficiency can be improved. There is a lot of work that needs to be done, we will focus on these for v2.0.0