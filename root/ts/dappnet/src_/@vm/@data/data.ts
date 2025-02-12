import type { ArithmeticData } from "src_/@vm/@data/s_mod";
import type { BytesData } from "src_/@vm/@data/s_mod";
import type { AddressData } from "src_/@vm/@data/s_mod";
import type { BooleanData } from "src_/@vm/@data/s_mod";
import type { StringData } from "src_/@vm/@data/s_mod";
import type { ArrayData } from "src_/@vm/@data/s_mod";
import type { StructData } from "src_/@vm/@data/s_mod";

export type Data =
    | ArithmeticData
    | BytesData
    | AddressData
    | BooleanData
    | StringData
    | ArrayData
    | StructData;