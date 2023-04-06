// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Terminal {
    struct Connection {
        bool isRootModule;
        string moduleType;
        address domain;
    }

    struct TimedConnection {
        /* if it is a root module when the connection expires it will only issue an event warning */
        bool isRootModule;
        string moduleType;
        address domain;
        uint256 duration;
        uint256 startOn;
        uint256 endOn;
    }

    function connectTo(
        bool _isRootModule,
        string memory _moduleType,
        address _domain
    ) internal returns (Connection memory) {
        Connection memory connection;
        connection.isRootModule = _isRootModule;
        connection.moduleType = _moduleType;
        connection.domain = _domain;
        return connection;
    }

    function connectToTimed(
        bool _isRootModule,
        string memory _moduleType,
        address _domain,
        uint256 _duration
    ) internal returns (TimedConnection memory) {
        TimedConnection memory connection;
        connection.isRootModule = _isRootModule;
        connection.moduleType = _moduleType;
        connection.domain = _domain;
        connection.duration = _duration;
        connection.startOn = block.timestamp;
        connection.endOn = connection.startOn + _duration;
        return connection;
    }
}
