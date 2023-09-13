// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

import "contracts/polygon/libraries/Match.sol";

import "contracts/polygon/State.sol";

contract Terminal {
    struct Meta { string name; }

    Meta private _meta;

    State[] private _modules;

    address admin;

    mapping(string => uint256) private _modulesMapping;
    mapping(uint256 => bool) private _terminated;

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    event Deploy(string indexed module, address indexed state);
    event Upgrade(string indexed module, address indexed newLogic, address indexed state);
    event Rename(string indexed module, string indexed newModule, address indexed state);
    event Terminate(string indexed module, address indexed state);

    constructor(string memory name_) {
        admin = msg.sender;
        _meta.name = name_;
        _modules.push(new State(""));
    }

    function name() public view returns (string memory) {
        return _meta.name;
    }

    function access(string memory module, bytes32 location) public view returns (bytes memory) {
        _reqInUse(module);
        return _modules[_modulesMapping[module]].access(location);
    }

    function version(string memory module) public view returns (uint256) {
        _reqInUse(module);
        return _modules[_modulesMapping[module]].version();
    }

    function latest(string memory module) public view returns (address) {
        _reqInUse(module);
        return _modules[_modulesMapping[module]].latest();
    }

    function previous(string memory module, uint index) public view returns (address) {
        _reqInUse(module);
        return _modules[_modulesMapping[module]].previous(index);
    }

    function empty(string memory module, bytes32 location) public view returns (bool) {
        _reqInUse(module);
        return _modules[_modulesMapping[module]].empty(location);
    }

    /// returns module data by using string search
    function modules(string memory module) public view 
    returns (
        string memory module_,
        address state,
        address logic,
        uint256 version_,
        bool terminated_
    ) {
        return (
            _modules[_modulesMapping[module]].module(),
            address(_modules[_modulesMapping[module]]),
            _modules[_modulesMapping[module]].latest(),
            _modules[_modulesMapping[module]].version(),
            _terminated[_modulesMapping[module]]
        );
    }

    /// returns module data by using index note index 0 is used as default
    function modulesIndexed(uint256 index) public view
    returns (
        string memory module,
        address state,
        address logic,
        uint256 version_,
        bool terminated_
    ) {
        return (
            _modules[index].module(),
            address(_modules[index]),
            _modules[index].latest(),
            _modules[index].version(),
            _terminated[_modulesMapping[module]]
        );
    }

    function count() public view returns (uint256) {
        return _modules.length;
    }

    /// deploys new State contract as a module
    function deploy(string memory module) public onlyAdmin {
        _reqNotInUse(module);
        _modules.push(new State(module));
        _modulesMapping[module] = _modules.length - 1;
        emit Deploy(module, address(_modules[_modulesMapping[module]]));
    }

    /// upgrades existing State contract logic
    function upgrade(string memory module, address newLogic) public onlyAdmin {
        _reqInUse(module);
        _modules[_modulesMapping[module]].upgrade(newLogic);
        emit Upgrade(module, newLogic, address(_modules[_modulesMapping[module]]));
    }

    /// change name of a current module to a new name
    function rename(string memory module, string memory newModule) public onlyAdmin {
        _reqInUse(module);
        _reqNotInUse(newModule);
        _modulesMapping[newModule] = _modulesMapping[module];
        delete _modulesMapping[module];
        _modules[_modulesMapping[newModule]].update(newModule);
        emit Rename(module, newModule, address(_modules[_modulesMapping[module]]));
    }

    /// THIS BREAKS THE VIEW FUNCTION
    /// WARNING: will permanently lock a State contract and it will no longer be able to store new data
    function terminate(string memory module) public onlyAdmin {
        _reqInUse(module);
        _modules[_modulesMapping[module]].lock();
        _terminated[_modulesMapping[module]] = true;
        delete _modules[_modulesMapping[module]];
        delete _modulesMapping[module];
        emit Terminate(module, address(_modules[_modulesMapping[module]]));
    }

    function _onlyAdmin() private view {
        require(msg.sender == admin, "msg.sender != admin");
    }

    function _reqNotInUse(string memory module) private view {
        require(_modulesMapping[module] == 0, "Terminal: module name in use");
    }

    function _reqInUse(string memory module) private view {
        require(_modulesMapping[module] != 0, "Terminal: module name not in use");
    }
}