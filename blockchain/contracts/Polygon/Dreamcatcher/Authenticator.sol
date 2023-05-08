// SPDX-License-Identifier: BSD-2-Clause
pragma solidity ^0.8.0;

interface IAuthenticator {
    function main() public view returns (address);
    function admin() public view returns (address);
    function owner(address _domain) public view returns (bool);
    function board(address _domain) public view returns (bool);
    function executive(address _domain) public view returns (bool);

    function _setAdmin_(address _newDomain) public;
    function _setOwner_(address _domain, bool _toggle) public;
    function _setBoard_(address _domain, bool _toggle) public;
    function _setExecutive_(address _domain, bool _toggle) public;
}

contract Authenticator is IAuthenticator {
    struct Code {
        address main;
    } Code private code;
    address admin;
    mapping(address=>bool) private isOwner;
    mapping(address=>bool) private isBoard;
    mapping(address=>bool) private isExecutive;

    function main() public view returns (address) {return code.main;}
    function admin() public view returns (address) {return admin;}
    function owner(address _domain) public view returns (bool) {return isOwner[_domain];}
    function board(address _domain) public view returns (bool) {return isBoard[_domain];}
    function executive(address _domain) public view returns (bool) {return isExecutive[_domain];}

    modifier main() {
        require(msg.sender == code.main);
        _;
    }

    function _setAdmin_(address _newDomain) public main {admin = _newDomain;}
    function _setOwner_(address _domain, bool _toggle) public main {
        isOwner[_domain] = _toggle;
    }

    function _setBoard_(address _domain, bool _toggle) public main {
        isBoard[_domain] = _toggle;
    }

    function _setExecutive_(address _domain, bool _toggle) public main {
        isExecutive[_domain] = _toggle;
    }
}