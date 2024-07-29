import { Wallet } from "ethers";
import { JsonRpcProvider } from "ethers";
import { Evm } from "@evm";
import { Sol } from "@sol";
import { join } from "path";
import { isSolOkStruct } from "@sol";

(async function() {
    let url = process?.env?.["TESTNET"]!;
    let key = process?.env?.["TESTNET_KEY"]!;
    let network = new JsonRpcProvider(url);
    let signer = new Wallet(key, network);
    let evm = Evm(signer);

    let usdc = "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359";
    let weth = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";

    let vTokenSol = Sol(join(__dirname, "../../contract/VToken.sol")).unwrap();
    if (!isSolOkStruct(vTokenSol)) {
        vTokenSol.errors.forEach(error => console.error(error));
        return;
    }
    let vTokenReceipt = (await evm.deploy({ bytecode: vTokenSol.bytecode, abi: vTokenSol.abi, args: ["TestToken", "vTT"] })).unwrap();
    let vTokenAddress = vTokenReceipt?.contractAddress;

    let vaultSol = Sol(join(__dirname, "../../contract/Vault.sol")).unwrap();
    if (!isSolOkStruct(vaultSol)) {
        vaultSol.errors.forEach(error => console.error(error));
        return;
    }
    let vaultReceipt = (await evm.deploy({
        bytecode: vaultSol.bytecode, 
        abi: vaultSol.abi, 
        args: [
            vTokenAddress, 
            [
                [
                    weth, 
                    usdc, 
                    [
                        weth, 
                        usdc
                    ], 
                    [
                        usdc, 
                        weth
                    ], 
                    BigInt(50 * 10**18)
                ]
            ]
        ] 
    })).unwrap();
    let vaultAddress =  vaultReceipt?.contractAddress;
    if (!vaultAddress) {
        console.error("unable to get vault address");
        return;
    }

    (await evm.call({
        to: vTokenAddress!,
        methodSignature: "function transferOwnership(address) external",
        methodName: "transferOwnership",
        methodArgs: [vaultAddress!]
    })).unwrap();

    let assetStructSignature: string = "(address,address,address[],address[])";
    let quoteStructSignature: string = "(uint256,uint256,uint256)";

    await vaultStateToLogs();
    await mint(1);
    await vaultStateToLogs();
    await mint(1);
    await vaultStateToLogs();
    await burn(500_000);
    await vaultStateToLogs();
    await mint(0.25);
    await vaultStateToLogs();
    await mint(0.001);
    await vaultStateToLogs();
    await burn(1_000_000);
    await rebalance();
    await vaultStateToLogs();
    await burn(100);
    await vaultStateToLogs();
    await mint(1);
    await vaultStateToLogs();
    await mint(1);
    await vaultStateToLogs();
    await rebalance();
    await vaultStateToLogs();

    async function vaultStateToLogs(): Promise<void> {
        let totalAssets_ = await totalAssets();
        let totalSupply_ = await totalSupply();
        let quote_ = await quote();
        console.log({
            realTotalAssets: totalAssets_.realTotalAssets,
            bestTotalAssets: totalAssets_.bestTotalAssets,
            totalAssetsSlippage: totalAssets_.slippage,
            realQuote: quote_.realQuote,
            bestQuote: quote_.bestQuote,
            quoteSlippage: quote_.slippage,
            totalSupply: totalSupply_
        });
    }
    
    async function rebalance(): Promise<void> {
        (await evm.call({
            to: vaultAddress!,
            methodSignature: "function rebalance() external",
            methodName: "rebalance",
            methodArgs: []
        })).unwrap();
    }

    async function mint(assetsIn: number): Promise<void> {
        let decimals: bigint = (await evm.query({
            to: usdc!,
            methodSignature: "function decimals() external view returns (uint8)",
            methodName: "decimals"
        })).unwrap() as bigint;
        (await evm.call({
            to: usdc!,
            methodSignature: "function approve(address,uint256) external",
            methodName: "approve",
            methodArgs: [vaultAddress!, BigInt(assetsIn * (10**Number(decimals)))]
        })).unwrap();
        (await evm.call({
            to: vaultAddress!,
            methodSignature: "function mint(uint256) external",
            methodName: "mint",
            methodArgs: [BigInt(assetsIn * 10**18)]
        })).unwrap();
    }

    async function burn(supplyIn: number): Promise<void> {
        (await evm.call({
            to: vTokenAddress!,
            methodSignature: "function approve(address,uint256) external",
            methodName: "approve",
            methodArgs: [vaultAddress!, BigInt(supplyIn * 10**18)]
        })).unwrap();
        (await evm.call({
            to: vaultAddress!,
            methodSignature: "function burn(uint256) external",
            methodName: "burn",
            methodArgs: [BigInt(supplyIn * 10**18)]
        })).unwrap();
    }

    async function quote(): Promise<{
        realQuote: number,
        bestQuote: number,
        slippage: number
    }> {
        let quote: any[] = (await evm.query({
            to: vaultAddress!,
            methodSignature: `function quote() external view returns (${ quoteStructSignature })`,
            methodName: "quote"
        })).unwrap() as any[];
        return {
            realQuote: format(quote[0]),
            bestQuote: format(quote[1]),
            slippage: format(quote[2])
        };
    }

    async function totalAssets(): Promise<{
        realTotalAssets: number,
        bestTotalAssets: number,
        slippage: number
    }> {
        let quote: any[] = (await evm.query({
            to: vaultAddress!,
            methodSignature: `function totalAssets() external view returns (${ quoteStructSignature })`,
            methodName: "totalAssets"
        })).unwrap() as any[];
        return {
            realTotalAssets: format(quote[0]),
            bestTotalAssets: format(quote[1]),
            slippage: format(quote[2])
        };
    }

    async function totalSupply(): Promise<number> {
        return format((await evm.query({
            to: vaultAddress!,
            methodSignature: "function totalSupply() external view returns (uint256)",
            methodName: "totalSupply"
        })).unwrap() as bigint);
    }

    async function transfer(token: string, to: string, amount: number): Promise<void> {
        let decimals = (await evm.query({
            to: token,
            methodSignature: "function decimals() external view returns (uint8)",
            methodName: "decimals"
        })).unwrap() as bigint;
        (await evm.call({
            to: token, 
            methodSignature: "function approve(address,uint256) external",
            methodName: "approve",
            methodArgs: [to, BigInt(amount * (10**(Number(decimals))))]
        })).unwrap();
        (await evm.call({
            to: token,
            methodSignature: "function transfer(address,uint256) external",
            methodName: "transfer",
            methodArgs: [to, BigInt(amount * (10**(Number(decimals))))]
        })).unwrap();
    }
})();

function format(ether: bigint): number {
    return Number(ether) / 10**18;
}