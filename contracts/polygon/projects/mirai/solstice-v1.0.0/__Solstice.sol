// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;
import "contracts/polygon/templates/____Storage.sol";
import "contracts/polygon/projects/mirai/solstice-v1.0.0/__Encoder.sol";
import "contracts/polygon/deps/openzeppelin/utils/structs/EnumerableSet.sol";
import "contracts/polygon/deps/openzeppelin/token/ERC20/IERC20.sol";
import "contracts/polygon/projects/mirai/solstice-v1.0.0/Token.sol";

library __Solstice {
    function convertToWei(uint value)
        public view
        returns (uint) {
        return value * (10**18);
    }

    function amountToMint(uint v, uint s, uint b)
        public pure
        returns (uint) {
        require(v >= convertToWei(1), "__Solstice: insufficient value (v)");
        require(s >= convertToWei(1), "__Solstice: insufficient value (s)");
        require(b >= convertToWei(1), "__Solstice: insufficient value (b)");
        return ((v * s) / b);
    }

    function monetize(address token, address from, address to, uint amount)
        public {
        bool success = IERC20(token).transferFrom(from, to, amount);
        require(success, "__Solstice: unable to make transfer due to unsuccessful transfer");
    }

    /**
    * @param storage_ is the address of the eternal storage
    * @param name is the name of the fund
    * @param description a short description of the fund
    * @param maxSupply the maximum amount of tokens to be issued for this fund
    * @param required is the amount of matic that needs to be raised to start trading
    * @param duration is the length of the initial funding round
    * @param onlyWhitelisted only whitelisted addresses can participate
    * @param tokenName the name given to the token of this fund
    * @param tokenSymbol the symbol given to the token of this fund
     */
    function createNewFund(
        address storage__,
        address dreamToken,
        address vault,
        string memory name,
        string memory description,
        uint maxSupply,
        uint required,
        uint duration,
        bool onlyWhitelisted,
        string memory tokenName,
        string memory tokenSymbol,
        address creator,
        address[] memory admins,
        address[] memory managers
        ) public {
        require(maxSupply >= convertToWei(10000), "__Solstice: insufficient maxSupply");
        require(required >= convertToWei(0.1), "__Solstice: required amount of matic is too low");
        require(duration >= 3600 seconds, "__Solstice: duration is too low");
        // create storage interface
        ____IStorage storage_ = ____IStorage(storage__);
        // import count, increase by 1, and update count
        uint index = storage_.getUintStorage(__Encoder.encode("count")) + 1;
        storage_.setUintStorage(__Encoder.encode("count"), index);
        // check if the called index is in use, if so this must never be the case as it may corrupt someone elses data
        assert(
            storage_.getStringStorage(__Encoder.encodeWithIteration("name", index)) == ""
            && storage_.getStringStorage(__Encoder.encodeWithIteration("description", index)) == ""
            && storage_.getUintStorage(__Encoder.encodeWithIteration("required", index)) == 0
            && storage_.getUintStorage(__Encoder.encodeWithIteration("duration", index)) == 0
            && storage_.getAddressStorage(__Encoder.encodeWithIteration("creator", index)) == address(0x0)
            && storage_.getAddressStorage(__Encoder.encodeWithIteration("token", index)) == address(0x0)
            && storage_.lengthAddressSetStorage(__Encoder.encodeWithIteration("whitelist", index)) == 0
            && storage_.lengthAddressSetStorage(__Encoder.encodeWithIteration("admins", index)) == 0
            && storage_.lengthAddressSetStorage(__Encoder.encodeWithIteration("managers", index)) == 0,
            "__Solstice: critical error > index is not default"
        );
        // request payment
        monetize(dreamToken, msg.sender, vault, storage_.getUintStorage(__Encoder.encode("gasCreate")));
        // set new fund parameters
        storage_.setStringStorage(__Encoder.encodeWithIteration("name", index), name);
        storage_.setStringStorage(__Encoder.encodeWithIteration("description", index), description);
        storage_.setUintStorage(__Encoder.encodeWithIteration("required", index), required);
        uint now_ = block.timestamp;
        storage_.setUintStorage(__Encoder.encodeWithIteration("startTimestamp", index), now_);
        storage_.setUintStorage(__Encoder.encodeWithIteration("endTimestamp", index), now_ + duration);
        storage_.setUintStorage(__Encoder.encodeWithIteration("duration", index), duration);
        storage_.setBooleanStorage(__Encoder.encodeWithIteration("isApproved", index), false);
        storage_.setBooleanStorage(__Encoder.encodeWithIteration("isRejected", index), false);
        storage_.setBooleanStorage(__Encoder.encodeWithIteration("isTrading", index), false);
        storage_.setBooleanStorage(__Encoder.encodeWithIteration("onlyWhitelisted", index), onlyWhitelisted);
        storage_.setAddressStorage(__Encoder.encodeWithIteration("token", index), address(new Token(tokenName, tokenSymbol, maxSupply)));
        storage_.setAddressStorage(__Encoder.encodeWithIteration("creator", index), msg.sender);
        storage_.setUintStorage(__Encoder.encodeWithIteration("netAssetValue", index), 0);
        storage_.setUintStorage(__Encoder.encodeWithIteration("netAssetValuePerShare", index), 0);
        // here we append admins and managers to designated enumerableSets
        for (uint i = 0; i < admins.length; i++) {
            storage_.addAddressSetStorage(__Encoder.encodeWithIteration("admins", index), admins[i]);
        }
        for (uint i = 0; i < managers.length; i++) {
            storage_.addAddressSetStorage(__Encoder.encodeWithIteration("managers", index), managers[i]);
        }
    }

    function updateNetAssetValue()
        public {
        
    }

    function contribute(address storage__, address dreamToken, address vault, uint index, uint value)
        public payable {
        // update overall contribution data
        uint value = storage_.getUintStorage(__Encoder.encodeWithIterationAndAccount("contribution", index, msg.sender));
        storage_.setUintStorage(__Encoder.encodeWithIterationAndAccount("contribution", index, msg.sender), value += msg.value);
        // issue new tokens
        address token = storage_.getAddressStorage(__Encoder.encodeWithIteration("token", index));
        amountToMint(msg.value, IERC20(token).totalSupply(), b);
    }
}