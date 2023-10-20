# Structure of Storage Slot Declaration

`function example() public view virtual returns (datatype)`
`perform action? public virtual`
`function ____example() internal pure virtual returns (bytes32)`
`function _setExample(args) internal virtual`

---

Unlike normal solidity code variables must be declared in this fashion. This is to allow cross compatibility through out all contracts and avoid storage vulnerabilities.