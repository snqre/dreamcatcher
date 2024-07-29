import { BrowserProvider } from "ethers";
import { JsonRpcSigner } from "ethers";
import { Contract } from "ethers";
import { TransactionReceipt } from "ethers";
import { Interface } from "ethers";
import { Ok } from "ts-results";
import { Err } from "ts-results";

/** @state */
let _provider: BrowserProvider;

/** @public */
async function provider():
    Promise<
        | Ok<BrowserProvider>
        | Err<Error>
        | Err<"windowNotFound"> 
        | Err<"metamaskNotInstalled"> 
        | Err<"voidErr"> 
    > {
    if (!window) {
        return Err<"windowNotFound">("windowNotFound");
    }
    if (!(window as any).ethereum) {
        return Err<"metamaskNotInstalled">("metamaskNotInstalled");
    }
    _provider = new BrowserProvider((window as any).ethereum);
    try {
        let accounts: string[] = await _provider.send("eth_accounts", []);
        if (accounts.length > 0) {
            return Ok<BrowserProvider>(_provider);
        }
        else {
            await _provider.send("eth_requestAccounts", []);
            return Ok<BrowserProvider>(_provider);
        }
    }
    catch (error: unknown) {
        if (error instanceof Error) {
            return Err<Error>(error);
        }
        return Err<"voidErr">("voidErr")
    }
}

/** @public */
async function chainId(): 
    Promise<
        | Ok<bigint>
        | Err<Error>
        | Err<"windowNotFound"> 
        | Err<"metamaskNotInstalled"> 
        | Err<"voidErr"> 
    > {
    let provider_ = await provider();
    if (provider_.err) {
        return provider_;
    }
    return Ok<bigint>((await provider_.unwrap().getNetwork()).chainId);
}

/** @public */
async function signer(): 
    Promise<
        | Ok<JsonRpcSigner>
        | Err<Error>
        | Err<"windowNotFound"> 
        | Err<"metamaskNotInstalled"> 
        | Err<"voidErr"> 
    > {
    let provider_ = await provider();
    if (provider_.err) {
        return provider_;
    }
    return Ok<JsonRpcSigner>(await provider_.unwrap().getSigner());
}

/** @public */
async function signerAddress(): 
    Promise<
        | Ok<string>
        | Err<Error>
        | Err<"windowNotFound"> 
        | Err<"metamaskNotInstalled"> 
        | Err<"voidErr">
    > {
    let signer_ = await signer();
    if (signer_.err) {
        return signer_;
    }
    return Ok<string>(await signer_.unwrap().getAddress());
}

/** @public */
async function generateNonce(): 
    Promise<
        | Ok<number>
        | Err<Error>
        | Err<"windowNotFound"> 
        | Err<"metamaskNotInstalled"> 
        | Err<"voidErr">
    > {
    let signer_ = await signer();
    if (signer_.err) {
        return signer_;
    }
    return Ok<number>(await signer_.unwrap().getNonce());
}

/** @public */
async function query({
    to,
    methodSignature,
    methodName,
    methodArgs=[]
}: {
    to: string,
    methodSignature: string,
    methodName: string,
    methodArgs?: unknown[]
}): Promise<
    | Ok<unknown>
    | Err<Error>
    | Err<"windowNotFound"> 
    | Err<"metamaskNotInstalled"> 
    | Err<"voidErr"> 
> {
    let provider_ = await provider();
    if (provider_.err) {
        return provider_;
    }
    try {
        return Ok<unknown>(await (new Contract(to, [methodSignature], (provider_.unwrap()))).getFunction(methodName)(... methodArgs));
    }
    catch (error: unknown) {
        if (error instanceof Error) {
            return Err<Error>(error);
        }
        return Err<"voidErr">("voidErr")
    }
}

/** @public */
async function call({
    to,
    methodSignature,
    methodName,
    methodArgs=[],
    gasPrice=20000000000n,
    gasLimit=10000000n,
    value=0n,
    chainId,
    confirmations=1n
}: {
    to: string,
    methodSignature: string,
    methodName: string,
    methodArgs?: unknown[],
    gasPrice?: bigint,
    gasLimit?: bigint,
    value?: bigint,
    chainId?: bigint,
    confirmations?: bigint
}): Promise<
    | Ok<TransactionReceipt | null>
    | Err<Error>
    | Err<"windowNotFound"> 
    | Err<"metamaskNotInstalled"> 
    | Err<"signerUnavailable">
    | Err<"voidErr">
> {
    let signer_ = await signer();
    if (signer_.err) {
        return signer_;
    }
    let signerAddress_ = await signerAddress();
    if (signerAddress_.err) {
        return signerAddress_;
    }
    let nonce = await generateNonce();
    if (nonce.err) {
        return nonce;
    }
    try {
        return Ok<TransactionReceipt | null>(await (await signer_.unwrap().sendTransaction({
            from: signerAddress_.unwrap(),
            to: to,
            nonce: nonce.unwrap(),
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            chainId: chainId,
            value: value,
            data: new Interface([methodSignature]).encodeFunctionData(methodName, methodArgs)
        })).wait(Number(confirmations)));
    }
    catch (error: unknown) {
        if (error instanceof Error) {
            return Err<Error>(error);
        }
        return Err<"voidErr">("voidErr")
    }
}

/** @public */
async function deploy({
    bytecode,
    gasPrice=20000000000n,
    gasLimit=10000000n,
    value=0n,
    chainId,
    confirmations
}: {
    bytecode: string,
    gasPrice?: bigint,
    gasLimit?: bigint,
    value?: bigint,
    chainId?: bigint,
    confirmations?: bigint
}): Promise<
    | Ok<TransactionReceipt | null>
    | Err<Error>
    | Err<"windowNotFound"> 
    | Err<"metamaskNotInstalled"> 
    | Err<"signerUnavailable">
    | Err<"voidErr">
> {
    let signer_ = await signer();
    if (signer_.err) {
        return signer_;
    }
    let signerAddress_ = await signerAddress();
    if (signerAddress_.err) {
        return signerAddress_;
    }
    let nonce = await generateNonce();
    if (nonce.err) {
        return nonce;
    }
    try {
        return Ok<TransactionReceipt | null>(await (await signer_.unwrap().sendTransaction({
            from: signerAddress_.unwrap(),
            to: null,
            nonce: nonce.unwrap(),
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            chainId: chainId,
            value: value,
            data: `0x${bytecode}`
        })).wait(Number(confirmations)));
    }
    catch (error: unknown) {
        if (error instanceof Error) {
            return Err<Error>(error);
        }
        return Err<"voidErr">("voidErr")
    }
}

export { provider };
export { chainId };
export { signer };
export { signerAddress };
export { generateNonce };
export { query };
export { call };
export { deploy };