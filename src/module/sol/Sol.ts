import type { ErrCode } from "@result";
import type { ExecException } from "child_process";
import { Ok } from "ts-results";
import { Err } from "ts-results";
import { join } from "path";
import { exec } from "child_process";
import { readFileSync } from "fs";
import { unlinkSync } from "fs";
import { existsSync } from "fs";
/// @ts-ignore
import Solc from "solc";

type SolOkStruct = 
SolErrStruct & {
    bytecode: string;
    abi: object[];
    methods: {[x: string]: string};
}

type SolErrStruct = {
    path: string;
    errors: string[];
    warnings: string[];
}

function Sol(_path: string):
| Ok<SolOkStruct>
| Ok<SolErrStruct>
| Err<Error>
| Err<ExecException>
| Err<"pathNotFound">
| Err<"pathDoesNotHaveSolExtension">
| Err<"unableToParseName">
| Err<"unableToParseExtension">
| Err<"contentIsEmpty">
| Err<"corruptOutput">
| Err<"unsupportedErr"> {
    /** @constructor */ {
        if (!existsSync(_path)) {
            return Err<"pathNotFound">("pathNotFound");
        }
        let name: ReturnType<typeof _name> = _name(_path);
        if (name.err) {
            return name;
        }
        let extension: ReturnType<typeof _extension> = _extension(_path);
        if (extension.err) {
            return extension;
        }
        if (extension.unwrap() !== "sol") {
            return Err<"pathDoesNotHaveSolExtension">("pathDoesNotHaveSolExtension");
        }
        let tempPath: ReturnType<typeof _tempPath> = _tempPath(_path);
        if (tempPath.err) {
            return tempPath;
        }
        let sourcecode: ReturnType<typeof _sourcecode> = _sourcecode(_path, tempPath.unwrap());
        if (sourcecode.err) {
            return sourcecode;
        }
        if (sourcecode.unwrap() === "") {
            return Err<"contentIsEmpty">("contentIsEmpty");
        }
        let output: unknown = JSON.parse((Solc as any).compile(JSON.stringify({
            language: "Solidity",
            sources: {[name.unwrap()]: {
                content: sourcecode.unwrap()
            }},
            settings: {outputSelection: {"*": {"*": [
                "abi",
                "evm.bytecode",
                "evm.methodIdentifiers"
            ]}}}
        })));
        let errors: string[] = [];
        let warnings: string[] = [];
        let errorsOrWarnings: unknown[] = (output as any)?.errors ?? [];
        for (let i = 0; i < errorsOrWarnings.length; i += 1) {
            let errorOrWarning: unknown = errorsOrWarnings[i];
            if (!(
                errorOrWarning
                && typeof errorOrWarning === "object"
                && "severity" in errorOrWarning
                && "formattedMessage" in errorOrWarning
                && typeof errorOrWarning.severity === "string"
                && typeof errorOrWarning.formattedMessage === "string"
            )) {
                return Err<"corruptOutput">("corruptOutput");
            }
            if (errorOrWarning.severity === "error") {
                errors.push(errorOrWarning.formattedMessage);
            }
            else {
                warnings.push(errorOrWarning.formattedMessage);
            }
        }
        if (errors.length === 0) {
            let bytecode: unknown
                = (output as any)
                    ?.contracts
                    ?.[name.unwrap()]
                    ?.[name.unwrap()]
                    ?.evm
                    ?.bytecode
                    ?.object;
            let abi: unknown
                = (output as any)
                    ?.contracts
                    ?.[name.unwrap()]
                    ?.[name.unwrap()]
                    ?.abi;
            let methods: unknown
                = (output as any)
                    ?.contracts
                    ?.[name.unwrap()]
                    ?.[name.unwrap()]
                    ?.evm
                    ?.methodIdentifiers;
            if (!(
                bytecode
                && typeof bytecode === "string"
                && bytecode !== ""
            )) {
                return Err<"corruptOutput">("corruptOutput");
            }
            if (!(
                abi
                && Array.isArray(abi)
                && abi.length !== 0
                && typeof abi[0] === "object"
            )) {
                return Err<"corruptOutput">("corruptOutput");
            }
            if (!(
                methods
                && typeof methods === "object"
            )) {
                return Err<"corruptOutput">("corruptOutput");
            }
            let solOk: SolOkStruct = SolOkStruct();
            solOk.path = _path;
            solOk.errors = errors;
            solOk.warnings = warnings;
            solOk.bytecode = bytecode;
            solOk.abi = abi;
            solOk.methods = methods as {[x: string]: string};
            return Ok<SolOkStruct>(solOk);
        }
        let solErr: SolErrStruct = SolErrStruct();
        solErr.path = _path;
        solErr.errors = errors;
        solErr.warnings = warnings;
        return Ok<SolErrStruct>(solErr);
    }

    function SolOkStruct(): SolOkStruct {
        return {
            ... SolErrStruct(),

            bytecode: "",
            abi: [],
            methods: {}
        };
    }

    function SolErrStruct(): SolErrStruct {
        return {
            path: "",
            errors: [],
            warnings: []
        }
    }

    function _name(path: string):
    | Ok<string>
    | Err<"unableToParseName"> {
        let item: string | undefined
            = path
                ?.split("\\")
                ?.pop()
                ?.split(".")
                ?.at(-2);
        return !item
            ? Err("unableToParseName" as const)
            : Ok<string>(item);
    }

    function _extension(path: string):
    | Ok<string>
    | Err<"unableToParseExtension"> {
        let shards: string[] | undefined
            = path
                ?.split("/")
                ?.pop()
                ?.split(".");
        return !shards
            ? Err("unableToParseExtension" as const)
            : !(shards.at(-1))
                ? Err("unableToParseExtension")
                : Ok<string>((shards.at(-1)!));
    }

    function _tempPath(path: string):
    | Ok<string>
    | ErrCode<typeof _name>
    | ErrCode<typeof _extension> {
        let name: ReturnType<typeof _name> = _name(path);
        let extension: ReturnType<typeof _extension> = _extension(path);
        return name.err
            ? name
            : extension.err
                ? extension
                : Ok<string>(join(__dirname, `${name.unwrap()}.${extension.unwrap()}`));
    }

    function _sourcecode(path: string, tempPath: string):
    | Ok<string>
    | Err<Error>
    | Err<ExecException>
    | Err<"contentIsEmpty"> 
    | Err<"unsupportedErr"> {
        try {
            let exception!: 
            | ExecException 
            | null;
            exec(`bun hardhat flatten ${path} > ${tempPath}`, ex => exception = ex);
            let beginTimestamp: number = Date.now();
            let nowTimestamp: number = beginTimestamp;
            while(nowTimestamp - beginTimestamp < 4000) {
                nowTimestamp = Date.now();
            }
            if (exception) {
                return Err<ExecException>(exception);
            }
            let item: string = readFileSync(tempPath, "utf8");
            unlinkSync(tempPath);
            return item === ""
                ? Err<"contentIsEmpty">("contentIsEmpty")
                : Ok<string>(item);
        }
        catch (error: unknown) {
            return error instanceof Error
                ? Err<Error>(error)
                : Err<"unsupportedErr">("unsupportedErr");
        }
    }
}

function isSolOkStruct(item: unknown): item is SolOkStruct {
    if (
        item 
        && typeof item === "object"
        && "errors" in item
        && "warnings" in item
        && "bytecode" in item
        && "abi" in item
        && "methods" in item
        && Array.isArray(item.errors)
        && Array.isArray(item.warnings)
        && Array.isArray(item.abi)
        && typeof item.bytecode === "string"
        && typeof item.methods === "object"
        && item.errors.length === 0
    ) {
        return true
    }
    return false;
}

function isSolErrStruct(item: unknown): item is SolErrStruct {
    if (
        item 
        && typeof item === "object"
        && "errors" in item
        && "warnings" in item
        && Array.isArray(item.errors)
        && Array.isArray(item.warnings)
        && item.errors.length !== 0
    ) {
        return true;
    }
    return false;
}

export type { SolOkStruct };
export type { SolErrStruct };
export { Sol };
export { isSolOkStruct };
export { isSolErrStruct };