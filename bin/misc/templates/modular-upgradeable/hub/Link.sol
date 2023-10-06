// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/templates/modular-upgradeable/hub/Timelock.sol";
import "contracts/polygon/templates/modular-upgradeable/__Calls.sol";

contract Link is Timelock {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _terminals;
    mapping(address => EnumerableSet.AddressSet) private _routers;
    mapping(string => address) private _cache;

    function _onlyNotZeroAddress(address account)
        private pure {
        require(account != address(0), "Link: address is zero address");
    }

    function connect(string memory signature, bytes memory args)
        public
        returns (bool, bytes memory, address) {
        bool success;
        bytes memory response;
        address contract_;

        /// check cache if there has already been a successful call
        if (_cache[signature] != address(0)) {
            (success, response) = _cache[signature].call(abi.encodeWithSignature(signature, args));
            if (!success) { _cache[signature] = address(0); }
        }

        if (!success) {
            for (uint x = 0; x < _terminals.length(); x++) {
                address[] memory routers = _routers[_terminals.at(x)].values();
                (success, response, contract_) = __Calls.call(routers, signature, args);
                if (success) {
                    _cache[signature] = contract_;
                    break;
                }
                if (success) { break; }
            }
        }
        return (success, response, contract_);
    }

    function addTerminal(address terminal)
        public {
        validate(msg.sender, address(this), "addTerminal");
        _onlyNotZeroAddress(terminal);
        _terminals.add(terminal);
    }

    function removeTerminal(address terminal)
        public {
        validate(msg.sender, address(this), "removeTerminal");
        _onlyNotZeroAddress(terminal);
        _terminals.remove(terminal);
    }

    function addRouter(address terminal, address router)
        public {
        validate(msg.sender, address(this), "addRouter");
        _onlyNotZeroAddress(terminal);
        _onlyNotZeroAddress(router);
        require(_terminals.contains(terminal), "Link: invalid terminal address");
        _routers[terminal].add(router);
    }

    function removeRouter(address terminal, address router)
        public {
        validate(msg.sender, address(this), "removeRouter");
        _onlyNotZeroAddress(terminal);
        _onlyNotZeroAddress(router);
        require(_terminals.contains(terminal), "Link: invalid terminal address");
        _routers[terminal].remove(router);
    }

    function getTerminals()
        public view
        returns (address[] memory) {
        return _terminals.values();
    }

    function getRouters(address terminal)
        public view
        returns (address[] memory) {
        return _routers[terminal].values();
    }
}