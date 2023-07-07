// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;
import "contracts/polygon/deps/openzeppelin/access/Ownable.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";

interface IAuthenticator {
    event NewRoleCreated(string indexed caption, uint indexed access, uint indexed requiredGrantorAccess, uint max);

}

contract Authenticator is IAuthenticator, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /** ROLE ACCESS PERMISSIONS.
    * member        access lvl 1:     participate in elections and vote.
    *               access lvl 2:
    * syndicate     access lvl 3:     create multiSig proposal to directors, chancellor.
    * director      access lvl 4:     can sign multiSig proposals to transfer to public proposals.
    * chancellor    access lvl 5:     
    *               access lvl 6:
    *               access lvl 7:     
    *               access lvl 8:
    *               access lvl 9:     send instructions to key.
    * key           access lvl 10:    ownership.
     */
    
    EnumerableSet.AddressSet public tier_1;
    EnumerableSet.AddressSet public tier_2;
    EnumerableSet.AddressSet public tier_3;
    EnumerableSet.AddressSet public tier_4;
    EnumerableSet.AddressSet public tier_5;
    EnumerableSet.AddressSet public tier_6;
    EnumerableSet.AddressSet public tier_7;
    EnumerableSet.AddressSet public tier_8;
    EnumerableSet.AddressSet public tier_9;

    
    
    struct Role {
        string caption;
        uint access;
        EnumerableSet.AddressSet members;
        uint max;

        /// the access level required to grant this role.
        uint requiredGrantorAccess;
    }

    /// highest access an account has been granted. ie. if they are a member but also a chancellor they gain chancellor access.
    mapping(address => uint) public access;

    /** PROPOSAL ACCESS PERMISSIONS.
    sent with payload with proposals.
    higher level access require either longer timelock or more conditional checks. ie.
    * msg 50%, ch   access lvl 1:     temporarily pause non native modules for a few hours.
    * msg 60%, ch   access lvl 2:     allocate a 1% of the vault to a budget.
    * msg 75%, ch   access lvl 3:     raise or lower fees on mirai. change business settings on products. pause all modules for a day. ability to enact 7777 protocol assuming public concern.
    * public, msg   access lvl 4:     allocate a portion of the vault to budget.
    * public, msg   access lvl 5:
    * public, msg   access lvl 6:
    * public        access lvl 7:     select re election. allocate any amount of  vault to budget.
    * public        access lvl 8:     full re election. execute 1984s.
    * public        access lvl 9:    
    * public        access lvl 10:    upgrade. execute 4040s. execute 7777s.
     */

    mapping(string => Role) public roles;

    constructor(address owner) Ownable (owner) {
        
    }

    function _getHighestAccess(address account)
    private view
    returns (uint) {
        if (tier_9.contains(account)) { return 9; }
        else if (tier_8.contains(account)) { return 8; }
        else if (tier_7.contains(account)) { return 7; }
        else if (tier_6.contains(account)) { return 6; }
        else if (tier_5.contains(account)) { return 5; }
        else if (tier_4.contains(account)) { return 4; }
        else if (tier_3.contains(account)) { return 3; }
        else if (tier_2.contains(account)) { return 2; }
        else if (tier_1.contains(account)) { return 1; }
        else {
            return 0;
        }
    }

    function authenticate(address account, uint requiredAccess)
    public view
    returns (bool) {
        
        require(
            _getHighestAccess(account) >= requredAccess,
            "Authenticator: INSUFFICIENT_ACCESS"
        );

        return true;
    }

    function grant(address account, uint access)
    external
    returns (bool) {
        authenticate(msg.sender, 8);
        if (access == 1) { tier_1.add(account); }
        else if (access == 2) { tier_2.add(account); }
        else if (access == 3) { tier_3.add(account); }
        else if (access == 4) { tier_4.add(account); }
        else if (access == 5) { tier_5.add(account); }
        else if (access == 6) { tier_6.add(account); }
        else if (access == 7) { tier_7.add(account); }
        else if (access == 8) { tier_8.add(account); }
        else if (access == 9) { tier_9.add(account); }
        else {
            revert("Authenticator: UNRECOGNIZED_ACCESS_VALUE");
        }

        return true;
    }

    function revoke(address account)
    external
    returns (bool) {
        authenticate(msg.sender, 8);
        tier_1.remove(account);
        tier_2.remove(account);
        tier_3.remove(account);
        tier_4.remove(account);
        tier_5.remove(account);
        tier_6.remove(account);
        tier_7.remove(account);
        tier_8.remove(account);
        tier_9.remove(account);
    }

    function upgrade(address newImplementation)
    external
    returns (bool) {
        authenticate(msg.sender, 9);
        moduleManager.upgrade("authenticator", newImplementation);
        /// ... copy existing data
    }

}