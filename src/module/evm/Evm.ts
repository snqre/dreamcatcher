import type { ContractDeployTransaction } from "ethers";
import { Wallet } from "ethers";
import { Contract } from "ethers";
import { TransactionReceipt } from "ethers";
import { Interface } from "ethers";
import { ContractFactory } from "ethers";
import { Ok } from "ts-results";
import { Err } from "ts-results";

type Evm = {
    signer(): Wallet;
    signerAddress(): Promise<string>;
    generateNonce(): Promise<number>;
    query({
        to,
        methodSignature,
        methodName,
        methodArgs   
    }: {
        to: string,
        methodSignature: string,
        methodName: string,
        methodArgs?: unknown[]
    }): Promise<
        | Ok<unknown>
        | Err<Error>
        | Err<"voidErr">
    >;
    call({
        to,
        methodSignature,
        methodName,
        methodArgs,
        gasPrice,
        gasLimit,
        value,
        chainId,
        confirmations
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
        | Err<"voidErr">
    >;
    deploy({
        bytecode,
        abi,
        args,
        gasPrice,
        gasLimit,
        value,
        chainId,
        confirmations
    }: {
        bytecode: string,
        abi?: object[],
        args?: unknown[],
        gasPrice?: bigint,
        gasLimit?: bigint,
        value?: bigint,
        chainId?: bigint,
        confirmations?: bigint
    }): Promise<
        | Ok<TransactionReceipt | null>
        | Err<Error>
        | Err<"voidErr">
    >;
}

/** @class */
function Evm(_signer: Wallet): Evm {
    let self: Evm = {
        signer,
        signerAddress,
        generateNonce,
        query,
        call,
        deploy
    };

    /** @constructor */ {}

    /** @public */
    function signer(): Wallet {
        return _signer;
    }

    /** @public */
    async function signerAddress(): Promise<string> {
        return await _signer.getAddress();
    }

    /** @public */
    async function generateNonce(): Promise<number> {
        return await _signer.getNonce();
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
        | Err<"voidErr">
    > {
        try {
            return Ok<unknown>(await new Contract(to, [methodSignature], _signer).getFunction(methodName)(... methodArgs));
        }
        catch (error: unknown) {
            if (error instanceof Error) {
                return Err<Error>(error);
            }
            return Err<"voidErr">("voidErr");
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
        | Err<"voidErr">
    > {
        try {
            return Ok<TransactionReceipt | null>(await (await _signer.sendTransaction({
                from: await signerAddress(),
                to: to,
                nonce: await generateNonce(),
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
            return Err<"voidErr">("voidErr");
        }
    }

    /** @public */
    async function deploy({
        bytecode,
        abi,
        args,
        gasPrice=20000000000n,
        gasLimit=10000000n,
        value=0n,
        chainId,
        confirmations=1n
    }: {
        bytecode: string,
        abi?: object[],
        args?: unknown[],
        gasPrice?: bigint,
        gasLimit?: bigint,
        value?: bigint,
        chainId?: bigint,
        confirmations?: bigint
    }): Promise<
        | Ok<TransactionReceipt | null>
        | Err<Error>
        | Err<"voidErr">
    > {
        try {
            let transaction!: ContractDeployTransaction;
            if (abi && args) {
                let factory = new ContractFactory(abi, bytecode, _signer);
                transaction = await factory.getDeployTransaction(...args);
            }
            return Ok<TransactionReceipt | null>(await (await _signer.sendTransaction({
                from: await signerAddress(),
                to: null,
                nonce: await generateNonce(),
                gasPrice: gasPrice,
                gasLimit: gasLimit,
                chainId: chainId,
                value: value,
                data: 
                    (args && abi) 
                        ? transaction.data
                        : `0x${bytecode}`
            })).wait(Number(confirmations)));
        }
        catch (error: unknown) {
            if (error instanceof Error) {
                return Err<Error>(error);
            }
            return Err<"voidErr">("voidErr");
        }
    }

    return self;
}

export { Evm };