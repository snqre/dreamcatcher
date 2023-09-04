// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

/**
    Solstice Beta
    WARNING: This product is in Beta and is meant to be used as a mainnet test
 */

interface IQuickSwapOracle {
    function getPair(address tokenA, address tokenB) external view returns (address);
    function allPairs(uint index) external view returns (address);
    function getMetadata(address tokenA, address tokenB) external view returns (
        address address_,
        address addressA,
        address addressB,
        string memory nameA,
        string memory nameB,
        string memory symbolA,
        string memory symbolB,
        uint decimalsA,
        uint decimalsB
    );

    function getPrice(address tokenA, address tokenB, uint amount) external view returns (
        uint price,
        uint decimals,
        uint lastTimestamp
    );

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        address to
    ) external;

    function pause() external;
    function unpause() external;
}

interface ISolsticeSafeguardBeta {
    /** anyone */
    function getImplementations() external view returns (address[] memory);

    /** only implementations */
    function getAdmins() external view returns (address[] memory);
    function isAdmin(address account) external view returns (bool);
    function getManagers() external view returns (address[] memory);
    function isManager(address account) external view returns (bool);
    function getTokenContract(uint index) external view returns (address);
    function getTokenAmount(uint index) external view returns (uint);
    function getDenominator() external view returns (address);
    function willRejectAllDeposits() external view returns (bool);
    function getMinimumDeposit() external view returns (uint);
    function getMaximumDeposit() external view returns (uint);
    function getLockUpPeriod() external view returns (uint);
    function getCumulativeSlippageTolerance() external view returns (uint);
    function getManagementFee() external view returns (uint);
    function isWhitelistedAccount(address account) external view returns (bool);
    function isAssetForRedemption(address contract_) external view returns (bool);

    function addAdmin(address admin) external;
    function removeAdmin(address admin) external;
    function addManager(address manager) external;
    function removeManager(address manager) external;
    function setName(string memory newName) external;
    function setDescription(string memory newDescription) external;
    function setBalance(uint newBalance) external;
    function pushTokenContract(address newContract) external;
    function setTokenContract(uint index, address newContract) external;
    function pushTokenAmount(uint newAmount) external;
    function setTokenAmount(uint index, uint newAmount) external;
    function setDenominator(address newDenominator) external;
    function setRejectAllDeposits(bool enabled) external;
    function setMinimumDeposit(uint newMinimumDeposit) external;
    function setMaximumDeposit(uint newMaximumDeposit) external;
    function setLockUpPeriod(uint newLockUpPeriod) external;
    function setCumulativeSlippageTolerance(uint newCumulativeSlippageTolerance) external;
    function setManagementFee(uint newManagementFee) external;
    function addWhitelistedAccount(address account) external;
    function removeWhitelistedAccount(address account) external;
    function addAssetForRedemption(address contract_) external;
    function removeAssetForRedemption(address contract_) external;
    function setTokenName(string memory newTokenName) external;
    function setTokenSymbol(string memory newTokenSymbol) external;
    function setTokenDecimals(uint newTokenDecimals) external;
    function setTokenTotalSupply(uint newTokenTotalSupply) external;
    function setBalance(address account, uint newBalance) external;

    /** only factory */
    function addImplementation(address implementation) external;
    function removeImplementation(address implementation) external;
    function incrementImplementationCount() external returns (uint);
    
    /** owner */
    function setFactory(address factory_) external;
}

contract SolsticeBeta {
    IQuickSwapOracle public oracle;
    ISolsticeSafeguardBeta public safeguard;

    constructor(
        string memory name,
        string memory description,
        address denominator,
        bool rejectAllDeposits,
        uint minimumDeposit,
        uint maximumDeposit,
        uint lockUpPeriod,
        uint cumulativeSlippageTolerance,
        uint managementFee,
        address[] memory whitelistedAccounts,
        address[] memory assetsForRedemption,
        string memory nameToken,
        string memory symbolToken,
        uint decimalsToken
    ) {
        oracle = IQuickSwapOracle(0x1C334Ef8165BEC0db9Cbc0915B6c6d16E1e0da6C);
        safeguard = ISolsticeSafeguardBeta();
        safeguard.setName(name);
        safeguard.setDescription(description);
        safeguard.setDenominator(denominator);
        safeguard.setRejectAllDeposits(rejectAllDeposits);
        safeguard.setMinimumDeposit(minimumDeposit);
        safeguard.setMaximumDeposit(maximumDeposit);
        safeguard.setLockUpPeriod(lockUpPeriod);
        safeguard.setCumulativeSlippageTolerance(cumulativeSlippageTolerance);
        safeguard.setManagementFee(managementFee);
        for (uint i = 0; i < whitelistedAccounts.length; i++) {
            safeguard.addWhitelistedAccount(whitelistedAccounts[i]);
        }
        for (uint i = 0; i < assetsForRedemption.length; i++) {
            safeguard.addAssetForRedemption(assetsForRedemption[i]);
        }
        safeguard.setTokenName(nameToken);
        safeguard.setTokenSymbol(symbolToken);
        safeguard.setTokenDecimals(decimalsToken);
    }

    
    function deposit()
    public {

    }

    function withdraw()
    public {

    }

    function swap() 
    public {

    }

    
}