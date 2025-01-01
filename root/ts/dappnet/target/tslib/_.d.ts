type EvmAbstractBinaryInterface = EvmSignature | Array<object>;

type EvmArithmetic = "uint" | "int" | `${"uint" | "int"}${EvmArithmeticBitSize}`;

type EvmArithmeticBitSize = "8" | "16" | "24" | "32" | "40" | "48" | "56" | "64" | "72" | "80" | "88" | "96" | "104" | "112" | "120" | "128" | "136" | "144" | "152" | "160" | "168" | "176" | "184" | "192" | "200" | "208" | "216" | "224" | "232" | "240" | "248" | "256";

type EvmArray = `${EvmArithmetic | EvmBytes | EvmBase}[]`;

type EvmBase = "address" | "string" | "bool";

type EvmBytecode = string;

type EvmBytes = "bytes" | `bytes${EvmBytesBitSize}`;

type EvmBytesBitSize = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "10" | "11" | "12" | "13" | "14" | "15" | "16" | "17" | "18" | "19" | "20" | "21" | "22" | "23" | "24" | "25" | "26" | "27" | "28" | "29" | "30" | "31" | "32";

type EvmDataType = EvmArithmetic | EvmBase | EvmArray | EvmStruct;
declare const EvmDataType: EvmDataTypeHandler;

type EvmStruct = Array<EvmDataType>;

type EvmEventSignature = `event ${string}(${string})`;
declare function EvmEventSignature(selector: EvmSelector): EvmEventSignature;

type EvmExternalPureSignature = `function ${string}(${string}) external pure returns (${string})`;
declare function EvmExternalPureSignature(selector: EvmSelector, ...out: Array<EvmDataType>): EvmExternalPureSignature;

type EvmExternalSignature = `function ${string}(${string}) external`;
declare function EvmExternalSignature(selector: EvmSelector): EvmExternalSignature;

type EvmExternalViewSignature = `function ${string}(${string}) external view returns (${string})`;
declare function EvmExternalViewSignature(selector: EvmSelector, ...out: Array<EvmDataType>): EvmExternalViewSignature;

type EvmSelector = `${string}(${string})`;
declare function EvmSelector(name: string, ...args: Array<EvmDataType>): EvmSelector;

type EvmSignature = EvmEventSignature | EvmExternalPureSignature | EvmExternalSignature | EvmExternalViewSignature;

type EvmDataTypeHandler = {
    toString(...args: Array<EvmDataType>): string;
};

export { type EvmAbstractBinaryInterface, type EvmArithmetic, type EvmArithmeticBitSize, type EvmArray, type EvmBase, type EvmBytecode, type EvmBytes, type EvmBytesBitSize, EvmDataType, type EvmDataTypeHandler, EvmEventSignature, EvmExternalPureSignature, EvmExternalSignature, EvmExternalViewSignature, EvmSelector, type EvmSignature, type EvmStruct };
