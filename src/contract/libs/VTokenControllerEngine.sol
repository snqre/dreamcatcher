// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19;
import { IVToken } from "../interfaces/standards-native/IVToken.sol";
import { Erc20HandlerEngine } from "./Erc20HandlerEngine.sol";

contract VTokenControllerEngine is Erc20HandlerEngine {
    IVToken internal _vToken;

    constructor(address vToken) {
        _vToken = IVToken(vToken);
        (Result memory result, uint8 decimals) = _decimals(_vToken);
        if (_isErr(result)) {
            _panic(result);
        }
        if (decimals != 18) {
            _panic(Err("vTokenDecimalsMustBe18"));
        }
    }

    function _totalSupply() internal view returns (Result memory, uint256) {
        try _vToken.totalSupply() returns (uint256 totalSupply) {
            return (Ok(), totalSupply);
        }
        catch Error(string memory reason) {
            return (Err(reason), 0);
        }
        catch {
            return (Err("unableToFetchVTokenTotalSupply"), 0);
        }
    }

    function _mint(address account, uint256 amount) internal returns (Result memory) {
        try _vToken.mint(account, amount) {
            return Ok();
        }
        catch Error(string memory reason) {
            return Err(reason);
        }
        catch {
            return Err("unableToMintAtVToken");
        }
    }

    function _burn(address account, uint256 amount) internal returns (Result memory) {
        try _vToken.burn(account, amount) {
            return Ok();
        }
        catch Error(string memory reason) {
            return Err(reason);
        }
        catch {
            return Err("unableToBurnAtAtVToken");
        }
    }
}