// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "contracts/polygon/proxy/lite/ProxyLite.sol";

contract ProxyLiteDeployer {

    event Deployed(address indexed newInstance);

    ProxyLite[] internal _deployed;

    function deploy(address newImplementation) public virtual returns (address) {
        return _deploy(newImplementation);
    }

    function _deploy(address newImplementation) internal virtual returns (address) {
        _deployed.push(new ProxyLite());
        uint i = _deployed.length - 1;
        _deployed[i].configure(address(newImplementation));
        emit Deployed(address(_deployed[i]));
        return address(_deployed[i]);
    }
}