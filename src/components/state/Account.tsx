import {BrowserProvider} from "ethers";
import {Requirement} from "@requirement";
import {Ok} from "ts-results";
import {Err} from "ts-results";
import * as Evm from "@evm-client"; 

class WindowNotFound extends Error {}
class ProviderNotFoundOrRejected extends Error {}


class Account {
    private constructor() {}
    private static _provider: null | BrowserProvider;

    public static connected(): boolean {
        return !!Account._provider;
    }

    public static async address(): Promise<string> {
        return (await Evm.signerAddress()).unwrapOr("");
    }

    public static async connect(): Promise<
        | Ok<true>
        | Err<WindowNotFound>
        | Err<ProviderNotFoundOrRejected>
    > {
        if (Account.connected()) {
            return true;
        }
        new Requirement(!!window, "Account::Connect::WindowNotFound");
        new Requirement(!!(window as any).ethereum, "Account::Connect::ProviderNotInstalledOrRejected");
        Account._provider = new BrowserProvider((window as any).ethereum);
        try {
            let accounts: string[] = await Account._provider.send("eth_accounts", []);
            if (accounts.length > 0) {
                return true;
            }
            else {
                await Account._provider.send("eth_requestAccounts", []);
                return true;
            }
        }
        catch {
            return false;
        }
    }

    public static async chainId(): Promise<bigint> {
        await Account.connect();
        let chainId = (await Account._provider?.getNetwork())?.chainId;
        new Requirement(!!chainId);
        return chainId!;
    }
}

export { Account };