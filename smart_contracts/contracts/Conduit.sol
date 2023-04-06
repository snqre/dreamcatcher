// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "smart_contractslibrariesTerminal.sol";

contract Conduit {
    event NewConnection(
        bool _isRootModule,
        string _moduleType,
        address _domain
    );
    event NewTimedConnection(
        bool _isRootModule,
        string _moduleType,
        address _domain,
        uint256 _duration
    );

    mapping(uint256 => Connection) private connection;
    

    constructor(address _domainToken, address _domainGovernor) {
        bool isRootModule;
        string moduleType;
        address domain;

        isRootModule = true;
        moduleType = "native_token";
        domain = _domainToken;
        mapConnection[0] = Terminal.connectTo(isRootModule, moduleType, domain);

        isRootModule = true;
        moduleType = "governor";
        domain = _domainGovernor;
        mapConnection[1] = Terminal.connectTo(isRootModule, moduleType, domain);

        /* add other rool modules required to operate ... */
    }

}
