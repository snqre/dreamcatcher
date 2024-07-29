import {Requirement} from "@requirement";
import {Account} from "@state/Account";
import {Axios} from "axios";

class Asset {
    public readonly TOKEN: string;
    public readonly CURRENCY: string;
    public readonly TKN_CUR_PATH: readonly string[];
    public readonly CUR_TKN_PATH: readonly string[];
    public readonly TARGET_ALLOCATION: bigint;

    public constructor({
        token,
        currency="0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359",
        tknCurPath=[token, currency],
        curTknPath=[currency, token],
        targetAllocation=0n,
    }: {
        token: string;
        currency?: string;
        tknCurPath: string[];
        curTknPath: string[];
        targetAllocation: bigint;
    }) {
        new Requirement(tknCurPath[0] === token);
        new Requirement(curTknPath[0] === currency);
        new Requirement(tknCurPath[tknCurPath.length - 1] === currency);
        new Requirement(curTknPath[curTknPath.length - 1] === token);
        new Requirement(targetAllocation <= 100n);
        this.TOKEN = token;
        this.CURRENCY = currency;
        this.TKN_CUR_PATH = [... tknCurPath];
        this.CUR_TKN_PATH = [... curTknPath];
        this.TARGET_ALLOCATION = targetAllocation;
    }
}

class Deployment {
    private static _tokenName: string = "";
    private static _tokenSymbol: string = "";
    private static _assets: Asset[] = [];

    public static async bytecode(): Promise<Option<string>> {
        try {
            return new Some<string>((await new Axios().get("/bytecode")).data);
        }
        catch {
            return None;
        }
    }

    public static async abi(): Promise<object[]> {
        return (await new Axios().get("/abi")).data;
    }

    public static setTokenName(name: string): void {
        this._tokenName = name;
        return;
    }

    public static setTokenSymbol(symbol: string): void {
        this._tokenSymbol = symbol;
        return;
    }

    public static addAsset(asset: Asset): void {
        this._assets.push(asset);
        return;
    }

    public static async deploy(): Promise<string> {
        if (Account.connected()) {
            return "";    
        }
        Account.connect();
        
    }
}

export { Asset };
export { Deployment };