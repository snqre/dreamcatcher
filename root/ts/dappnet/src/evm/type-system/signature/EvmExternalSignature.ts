import { EvmSelector } from "@$";

export type EvmExternalSignature = `function ${ string }(${ string }) external`;
export function EvmExternalSignature(selector: EvmSelector): EvmExternalSignature {
    return `function ${ selector } external`;
}