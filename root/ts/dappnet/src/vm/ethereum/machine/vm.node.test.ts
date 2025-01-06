import { ExternalViewSignature, type VmError } from "@core.vm.ethereum.node";
import { Selector } from "@core.vm.ethereum.node";
import { Vm } from "@core.vm.ethereum.node";
import { Query } from "@core.vm.ethereum.node";
import type { TransactionResponse } from "ethers";
import { Err, Ok, panic, Result, Unsafe } from "reliq";
import { toString } from "reliq";

/** @script */
let privateKey: string | undefined = process.env?.["POLYGON_PRIVATE_KEY"];
if (privateKey === undefined) panic("ERR_MISSING_PRIVATE_KEY");
let url: string = "https://polygon-mainnet.g.alchemy.com/v2/demo";
let to: string = "0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C";
let signature: ExternalViewSignature = ExternalViewSignature(Selector("feeTo"), "address");
let vm: Vm = Vm(url).unwrap();
(await vm.query(Query({ privateKey, to, signature })))
    .map(responseU => console.log(responseU.unwrap()))
    .mapErr(e => {
        console.log(
            e.code,
            e.data.toString(),
            e.message.toString(),
            e.reason.toString(),
            e.transaction.toString()
        );
    });