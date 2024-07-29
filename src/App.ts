import type { SolOkStruct } from "@sol";
import { Sol } from "@sol";
import { join } from "path";
import { transpileReactApp } from "doka-tools";
import { isSolErrStruct } from "@sol";
import * as Path from "path";
import Express from "express";

class AddressBook {
    private constructor() {}
    private static _book: string[] = [];

    public static book(): string[] {
        return this._book;
    }

    public static add(address: string) {
        this._book.push(address);
    }

    public static toJson() {
        return JSON.stringify(this.book());
    }
}

(async function() {
    console.log("loading sol ...");
    let vTokenSol = Sol(join(__dirname, "./contract/VToken.sol"));
    if (vTokenSol.err) {
        console.error("unable to load vault token sol");
        return;
    }
    if (isSolErrStruct(vTokenSol)) {
        console.error("unable to load vault token sol due to sourcecode error(s)");
        vTokenSol.unwrap().errors.forEach(error => console.error(error));
        return;
    }
    let vaultSol = Sol(join(__dirname, "./contract/Vault.sol"));
    if (vaultSol.err) {
        console.error("unable to load vault sol");
        return;
    }
    if (isSolErrStruct(vaultSol)) {
        console.error("unable to load vault sol due to sourcecode error(s)");
        vaultSol.unwrap().errors.forEach(error => console.error(error));
        return;
    }
    console.log("booting ...");
    let transpile = transpileReactApp(join(__dirname, "App.tsx"), __dirname);
    if (transpile.err) {
        console.error("transpile failed");
        return;
    }
    console.log(
        transpile
            .unwrap()
            .toString("utf8")
    );
    Express()
        .use(Express.static(__dirname))
        .use(Express.json())
        .get("/", async function(request, response) {
            response
                .status(200)
                .sendFile(Path.join(__dirname, "App.html"));
        })
        .get("/address-book", async (request, response) => {
            response
                .status(200)
                .send(AddressBook.toJson());
        })
        .get("/data", async (request, response) => {
            response
                .status(200)
                .send({
                    vToken: {
                        bytecode: (vTokenSol.unwrap() as SolOkStruct).bytecode,
                        abi: (vTokenSol.unwrap() as SolOkStruct).abi
                    },
                    vault: {
                        bytecode: (vaultSol.unwrap() as SolOkStruct).bytecode,
                        abi: (vaultSol.unwrap() as SolOkStruct).abi
                    }
                });
        })
        .post("/addAddress", async (request, response) => {
            
            let { address } = request.body;
            AddressBook.add(address);
            response
                .status(201)
                .json({ message: "added" });
        })
        .listen(3000n);
    console.log("server booted");
})();