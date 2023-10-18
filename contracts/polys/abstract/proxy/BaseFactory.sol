// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/abstract/proxy/Base.sol";
import "contracts/polygon/interfaces/proxy/IDefaultImplementation.sol";
import "contracts/polygon/external/openzeppelin/access/Ownable.sol";

contract BaseFactory is Ownable {

    /**
    * An array to keep track of deployed instances of the Base contract.
    */
    Base[] internal _deployed;

    /**
    * The address of the default implementation.
    */
    address internal _defaultImplementation;

    /**
    * Emitted when a new Base contract is deployed.
    * @param newBase The address of the newly deployed Base contract.
    */
    event Deployed(address indexed newBase);

    /**
    * @dev Constructor to set the default implementation address and transfer ownership to the deployer.
    * @param defaultImplementation The address of the default implementation.
    */
    constructor(address defaultImplementation) Ownable(msg.sender) {
        _defaultImplementation = defaultImplementation;
    }

    /**
    * @dev Returns the address of the default implementation.
    * @return The address of the default implementation.
    */
    function defaultImplementation() public view virtual returns (address) {
        return _defaultImplementation;
    }

    /**
    * @dev Returns the address of the deployed contract at the specified index.
    * @param deployedId The index of the deployed contract.
    * @return The address of the deployed contract.
    */
    function addressDeployedTo(uint256 deployedId) public view virtual returns (address) {
        return address(_deployed[deployedId]);
    }

    /**
    * @dev Deploys a new Base contract and returns its address.
    * @return The address of the newly deployed Base contract.
    */
    function deploy() public virtual returns (address) {
        _checkOwner();
        _deployed.push(new Base());
        uint256 id = _deployed.length - 1;
        _deployed[id].setInitialImplementation(defaultImplementation());
        IDefaultImplementation newBaseInterface = IDefaultImplementation(address(_deployed[id]));
        newBaseInterface.initialize();
        newBaseInterface.transferOwnership(msg.sender);
        emit Deployed(address(_deployed[id]));
        return address(_deployed[id]);
    }
}