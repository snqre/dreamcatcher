// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import 'contracts/polygon/deps/openzeppelin/utils/Context.sol';
import 'contracts/polygon/plug-in/storage/stAdmin.sol';

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
    /// important things.
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