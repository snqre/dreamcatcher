# Structure of Storage Slot Declaration

1. function example() public view virtual returns (datatype)
2. perform action? public virtual
3. function ____example() internal pure virtual returns (bytes32)
4. function _setExample(args) internal virtual

---

Unlike normal solidity code variables must be declared in this fashion. This is to allow cross compatibility through out all contracts and avoid storage vulnerabilities.