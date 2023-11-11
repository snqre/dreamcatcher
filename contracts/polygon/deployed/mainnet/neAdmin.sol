
/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neAdmin.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity 0.8.19;

contract stAdmin {
    bytes32 internal constant _ADMIN = keccak256('node.admin');

    struct StAdmin {
        address admin;
    }

    function admin() internal pure virtual returns (StAdmin storage s) {
        bytes32 location = _ADMIN;
        assembly {
            s.slot := location
        }
    }
}



/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neAdmin.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.19;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/** 
 *  SourceUnit: c:\Users\marco\OneDrive\Documents\GitHub\dreamcatcher\contracts\polygon\plug-in\neAdmin.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.19;
////import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
////import 'contracts/polygon/plug-in/storage/stAdmin.sol';

contract neAdmin is Context, stAdmin {
    event AdministrationTransferred(address oldAdmin, address newAdmin);

    /// Not to be confused with diamond owner which is responsible
    /// for upgrading and managing the diamond implementation.
    /// The admin is the default responsible role for each 
    /// implementation and logic in the facet.
    function getAdmin() public view virtual returns (address) {
        return admin().admin;
    }

    /// This is a really dumb idea never do this if the diamond
    /// contains value or is responsible already responsible for
    /// ////important things.
    ///
    /// This is okay if its a new diamond. It can always be redeployed
    /// if someone tries to front run it.
    function claim() public virtual {
        require(admin().admin == address(0), 'neAdmin: admin claimed');
        admin().admin = _msgSender();
        transferAdministration(_msgSender());
    }

    function transferAdministration(address newAdmin) public virtual {
        if (admin().admin != address(0)) {
            require(_msgSender() == admin().admin, 'neAdmin: only admin');
        }
        require(newAdmin != address(0), 'neAdmin: new admin is the zero address');
        address oldAdmin = admin().admin;
        admin().admin = newAdmin;
        emit AdministrationTransferred(oldAdmin, newAdmin);
    }
}
