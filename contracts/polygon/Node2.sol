// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface INode {

    /**
    * @dev External function to claim ownership of the node. This will
    *      set the caller as the owner.
    *
    * NOTE Any calls made to an identical function on the implementation
    *      side will not be called at the implementaion but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    function claim() external;

    /**
    * @dev External function to change the implementation of the node.
    *
    * NOTE Any calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
    *
    * NOTE Only the owner can call this function.
     */
    function upgradeTo(address newImplementation) external;

    /**
    * @dev External function to change the owner address.
    *
    * NOTE Any calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
    *
    * NOTE Only the owner can call this function.
     */
    function transferOwnership(address newOwner) external;
}

/**
* @dev The node functions as a standard EIP-1967 proxy but it is
*      called a node as it holds some additional inbuilt functionality
*      to communicate with other nodes on polygon. This is done to
*      manage multiple proxies in a convenient way and to allow
*      implementations to be cross compatible between different
*      nodes on polygon.
*
* WARNING: If the implementation contract's functions consume a large amount
*          of gas, it could lead to out-of-gas errors during delegate
*          calls. This could potentially cause unexpected behaviour or
*          denial of service.
*
* WARNING: The security of the system heavily relies on the owner key.
*          If the owner key is compromised, an attacker could take
*          control of the contract and potentially upgrade it to a
*          malicious version.
*
* WARNING: The contract relies on external contracts for its implementation.
*          If these external contracts have vulnerabilities or are
*          compromised it could impact the security of the entire system.
*
* WARNING: If the implementation contract has storage layout changed
*          between versions, it could lead to unexpected behaviour. It is
*          critical pay attention to storage layout and if new storage
*          must be added within the implementation keep track of it and
*          ensure they are declared in the proper storage slots.
*
* WARNING: External calls made within the contract, especially in the
*          __delegate function using assembly, should be carefully
*          validated and sanitized to avoid potential
*          vulnerabilities, such as reentrancy attacks.
*
* STANDARD When creating a custom node with node prefix it as
*          nd ie. neToken.
*
* ATTACK SURFACE:
* | fallback
* | receive
* | claim
* | upgradeTo
* | transferOwnership
 */
contract Node is INode {
    
    /** The following declarations are modifiable storage by the implementaion. */

    /** # 0
    * @dev This has been declared at storage slot 0. This is designed
    *      to be used not only for the bytes storage datatype but
    *      also as a way to store data in a flexible way without
    *      needing to declare further variables and reduce the risk
    *      of storage clashes. In addition, using data for all 'keys'
    *      means that there will be no 'key' collitions. In other words,
    *      'keys' will not be able to be used for the wrong datatype by
    *      accident.
    *
    * NOTE Using this approach will come with the downside of complexity
    *      and reducing readability. In addition, a certain structure is
    *      required to read and write data this way. The upside is that
    *      all implementations that follow the standard will be completely
    *      interchangable (to some extent) meaning that it would be
    *      possible to swap the implementation of a token node with
    *      the implementation of a safe or anything else.
    *
    * NOTE Other datatypes are also provided for convinience. Using
    *      using these will increase the risk of 'key' collisions but
    *      improve readability and are more convinient.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementaion
    *      side will not be called at the implementation but will call
    *      the node's function only. 
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => bytes) public d;

    /** # 1
    * @dev This has been declared at storage slot 1. This can be used
    *      to store uint data.
    * 
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => uint) public dUint;

    /** # 2
    * @dev This has been declared at storage slot 2. This can be used
    *      to store int data.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => int) public dInt;

    /** # 3
    * @dev This has been declared at storage slot 3. This can be used
    *      to store string data.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => string) public dString;

    /** # 4
    * @dev This has been declared at storage slot 4. This can be used
    *      to store bool data.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => bool) public dBool;

    /** # 5
    * @dev This has been declared at storage slot 5. This can be used
    *      to store address data.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => address) public dAddress;

    /** # 6
    * @dev This has been declared at storage slot 6. This can be used
    *      to store bytes32 data.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    mapping(string => bytes32) public d32;

    /**
    * @dev The owner is the default admin of the node and can be used
    *      by the implementation. The owner can upgrade the node and
    *      should typically be assigned to a governor contract and never
    *      to external addresses.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    address public owner;

    /** 
    * @dev The following declarations are used within the node (proxy).
    *      
    * NOTE These will still be available within the implementation but
    *      are not intended to be changed or modified.
    */

    /**
    * @dev This points to the current implementation.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    address public implementation;

    /**
    * @dev This points to the previous implementations. This is used to
    *      keep an on-chain smart contract readable record of the
    *      historic implementations used by the node. The reasoning for
    *      this is so that the 'registrar' can use this information
    *      to manage multiple nodes and perform actions.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    address[] public implementations;

    /**
    * @dev This points to the latest version of the implementation.
    *      The version number can be used to get previous implementaions
    *      using the implementations view function.
    *
    * NOTE This will generate an external view function to read the
    *      data within the contract publicly. This means that any
    *      calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    uint public version;

    /**
    * @dev This event is fired when the owner of the node is transferred
    *      to another address. This can fire if the transfer is to the
    *      same account.
    *
    * NOTE This event is reserved by the node.
     */
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /**
    * @dev This event is fired when the implementation of the node is
    *      changed. This can fire if the upgrade is to the same
    *      account.
    *
    * NOTE This event is reserved by the node.
     */
    event Upgraded(address indexed oldImplementation, address indexed newImplementation);

    /** Forwarding. */

    /**
    * @dev All calls made to this contract that do not reference an
    *      existing function identifier will be forwarded to the
    *      assigned implementation.
     */
    fallback() external payable virtual {
        __delegate(implementation);
    }

    /**
    * @dev All calls made to this contract that do not reference an
    *      existing function identifier will be forwarded to the
    *      assigned implementation.
     */
    receive() external payable virtual {
        __delegate(implementation);
    }

    /** Claiming */

    /**
    * @dev External function to claim ownership of the node. This will
    *      set the caller as the owner.
    *
    * NOTE Any calls made to an identical function on the implementation
    *      side will not be called at the implementaion but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
     */
    function claim() external virtual {
        __claim();
    }

    /**
    * NOTE This function is private and will not be passed on to
    *      the implementation which will inherit this contract.
    *
    * NOTE If the owner is transferred to address(0) this does not
    *      renounce ownership permanently but just resets the claim.
    *      This means if anyone else claims the node after its been
    *      set to zero, the new owner will become the new msg.sender.
    *      To permanently renounce ownership, transfer ownership to a
    *      void contract or to the node itself (assuming it does not
    *      have any logic to transfer its own ownership).
     */
    function __claim() private {
        require(owner == address(0), 'Node: already claimed');
        _transferOwnership(msg.sender);
    }

    /** Upgrading */

    /**
    * @dev External function to change the implementation of the node.
    *
    * NOTE Any calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
    *
    * NOTE Only the owner can call this function.
     */
    function upgradeTo(address newImplementation) external virtual {
        _onlyOwner();
        _upgradeTo(newImplementation);
    }

    /**
    * @dev This will upgrade the implementation to a new address. The
    *      new implementation MUST be a contract and this is enforced
    *      by checking the length of code on the address.
    *
    * NOTE This function is internal so it can be used by the
    *      implementation for additional logic or overrides.
    *
    * NOTE If version is being set for the first time the version
    *      should point to zero. Therefore, zero should point to
    *      the first implementation on the implementations
    *      view function.
     */
    function _upgradeTo(address newImplementation) internal virtual {
        require(newImplementation.code.length > 0, 'Node: implementation is not a contract');
        address oldImplementation = implementation;
        implementation = newImplementation;
        implementations.push(newImplementation);
        version = implementations.length - 1;
        emit Upgraded(oldImplementation, newImplementation);
    }

    /** Transferring ownership. */

    /**
    * @dev External function to change the owner address.
    *
    * NOTE Any calls made to an identical function on the implementation
    *      side will not be called at the implementation but will call
    *      the node's function only.
    *
    * NOTE This function is reserved by the node.
    *
    * NOTE Only the owner can call this function.
     */
    function transferOwnership(address newOwner) external virtual {
        _onlyOwner();
        _transferOwnership(newOwner);
    }

    /**
    * NOTE This function is internal so it can be used by the
    *      implementation for additional logic or overrides.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
    * @dev Standard internal view function to check if the caller is
    *      the owner of the node.
    *
    * NOTE This function is internal so it can be used by the
    *      implementation for additional logic or overrides.
     */
    function _onlyOwner() internal view virtual {
        require(owner == msg.sender, 'Node: unauthorized');
    }

    /** Proxy. */

    /**
    * @dev This will forward any calls to the route address.
    *
    * NOTE This function is private and will not be passed on to
    *      the implementation which will inherit this contract.
     */
    function __delegate(address route) private {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), route, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}