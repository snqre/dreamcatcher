import type { ILike } from "@root";
import type { ULike } from "@root";
import { Float } from "@root";
import { I } from "@root";
import { I8 } from "@root";
import { I16 } from "@root";
import { I32 } from "@root";
import { I64 } from "@root";
import { I128 } from "@root";
import { I256 } from "@root";
import { U } from "@root";
import { U8 } from "@root";
import { U16 } from "@root";
import { U32 } from "@root";
import { U64 } from "@root";
import { U128 } from "@root";
import { U256 } from "@root";
import { Result } from "@root";
import { MathError } from "@root";

export type Math = {
    eq(v0: Float, v1: Float): boolean;
    eq(v0: ILike, v1: ILike): boolean;
    eq(v0: ULike, v1: ULike): boolean;
    eq(v0: number, v1: number): boolean;
    eq(v0: bigint, v1: bigint): boolean;
    lt(v0: Float, v1: Float): boolean;
    lt(v0: ILike, v1: ILike): boolean;
    lt(v0: ULike, v1: ULike): boolean;
    lt(v0: number, v1: number): boolean;
    lt(v0: bigint, v1: bigint): boolean;
    gt(v0: Float, v1: Float): boolean;
    gt(v0: ILike, v1: ILike): boolean;
    gt(v0: ULike, v1: ULike): boolean;
    gt(v0: number, v1: number): boolean;
    gt(v0: bigint, v1: bigint): boolean;
    lteq(v0: Float, v1: Float): boolean;
    lteq(v0: ILike, v1: ILike): boolean;
    lteq(v0: ULike, v1: ULike): boolean;
    lteq(v0: number, v1: number): boolean;
    lteq(v0: bigint, v1: bigint): boolean;
    gteq(v0: Float, v1: Float): boolean;
    gteq(v0: ILike, v1: ILike): boolean;
    gteq(v0: ULike, v1: ULike): boolean;
    gteq(v0: number, v1: number): boolean;
    gteq(v0: bigint, v1: bigint): boolean;
    add(v0: Float, v1: Float): Result<Float, MathError>;
    add(v0: I, v1: I): Result<I, MathError>;
    add(v0: I, v1: I8): Result<I, MathError>;
    add(v0: I, v1: I16): Result<I, MathError>;
    add(v0: I, V1: I32): Result<I, MathError>;
    add(v0: I, v1: I64): Result<I, MathError>;
    add(v0: I, v1: I128): Result<I, MathError>;
    add(v0: I, v1: I256): Result<I, MathError>;
    add(v0: I8, v1: I): Result<I, MathError>;
    add(v0: I8, v1: I8): Result<I8, MathError>;
    add(v0: I8, v1: I16): Result<I16, MathError>;
    add(v0: I8, v1: I32): Result<I32, MathError>;
    add(v0: I8, v1: I64): Result<I64, MathError>;
    add(v0: I8, v1: I128): Result<I128, MathError>;
    add(v0: I8, v1: I256): Result<I256, MathError>;
    add(v0: I16, v1: I): Result<I, MathError>;
    add(v0: I16, v1: I8): Result<I16, MathError>;
    add(v0: I16, v1: I16): Result<I16, MathError>;
    add(v0: I16, v1: I32): Result<I32, MathError>;
    add(v0: I16, v1: I64): Result<I64, MathError>;
    add(v0: I16, v1: I128): Result<I128, MathError>;
    add(v0: I16, v1: I256): Result<I256, MathError>;
    add(v0: I32, v1: I): Result<I, MathError>;
    add(v0: I32, v1: I8): Result<I32, MathError>;
    add(v0: I32, v1: I16): Result<I32, MathError>;
    add(v0: I32, v1: I32): Result<I32, MathError>;
    add(v0: I32, v1: I64): Result<I64, MathError>;
    add(v0: I32, v1: I128): Result<I128, MathError>;
    add(v0: I32, v1: I256): Result<I256, MathError>;
    add(v0: I64, v1: I): Result<I, MathError>;
    add(v0: I64, v1: I8): Result<I64, MathError>;
    add(v0: I64, v1: I16): Result<I64, MathError>;
    add(v0: I64, v1: I32): Result<I64, MathError>;
    add(v0: I64, v1: I64): Result<I64, MathError>;
    add(v0: I64, v1: I128): Result<I128, MathError>;
    add(v0: I64, v1: I256): Result<I256, MathError>;
    add(v0: I128, v1: I): Result<I, MathError>;
    add(v0: I128, v1: I8): Result<I128, MathError>;
    add(v0: I128, v1: I32): Result<I128, MathError>;
    add(v0: I128, v1: I64): Result<I128, MathError>;
    add(v0: I128, v1: I128): Result<I128, MathError>;
    add(v0: I128, v1: I256): Result<I256, MathError>;
    add(v0: I256, v1: I): Result<I, MathError>;
    add(v0: I256, v1: I8): Result<I256, MathError>;
    add(v0: I256, v1: I16): Result<I256, MathError>;
    add(v0: I256, v1: I32): Result<I256, MathError>;
    add(v0: I256, v1: I64): Result<I256, MathError>;
    add(v0: I256, v1: I128): Result<I256, MathError>;
    add(v0: I256, v1: I256): Result<I256, MathError>;
    add(v0: U, v1: U): Result<U, MathError>;
    add(v0: U, v1: U8): Result<U, MathError>;
    add(v0: U, v1: U16): Result<U, MathError>;
    add(v0: U, v1: U32): Result<U, MathError>;
    add(v0: U, v1: U64): Result<U, MathError>;
    add(v0: U, v1: U128): Result<U, MathError>;
    add(v0: U, v1: U256): Result<U, MathError>;
    add(v0: U8, v1: U): Result<U, MathError>;
    add(v0: U8, v1: U8): Result<U8, MathError>;
    add(v0: U8, v1: U16): Result<U16, MathError>;
    add(v0: U8, v1: U32): Result<U32, MathError>;
    add(v0: U8, v1: U64): Result<U64, MathError>;
    add(v0: U8, v1: U128): Result<U128, MathError>;
    add(v0: U8, v1: U256): Result<U256, MathError>;
    add(v0: U16, v1: U): Result<U, MathError>;
    add(v0: U16, v1: U8): Result<U16, MathError>;
    add(v0: U16, v1: U16): Result<U16, MathError>;
    add(v0: U16, v1: U32): Result<U32, MathError>;
    add(v0: U16, v1: U64): Result<U64, MathError>;
    add(v0: U16, v1: U128): Result<U128, MathError>;
    add(v0: U16, v1: U256): Result<U256, MathError>;
    add(v0: U32, v1: U): Result<U, MathError>;
    add(v0: U32, v1: U8): Result<U32, MathError>;
    add(v0: U32, v1: U32): Result<U32, MathError>;
    add(v0: U32, v1: U64): Result<U64, MathError>;
    add(v0: U32, v1: U128): Result<U128, MathError>;
    add(v0: U32, v1: U256): Result<U256, MathError>;
    add(v0: U64, v1: U): Result<U, MathError>;
    add(v0: U64, v1: U8): Result<U64, MathError>;
    add(v0: U64, v1: U16): Result<U64, MathError>;
    add(v0: U64, v1: U32): Result<U64, MathError>;
    add(v0: U64, v1: U64): Result<U64, MathError>;
    add(v0: U64, v1: U128): Result<U128, MathError>;
    add(v0: U64, v1: U256): Result<U256, MathError>;
    add(v0: U128, v1: U): Result<U, MathError>;
    add(v0: U128, v1: U8): Result<U128, MathError>;
    add(v0: U128, v1: U16): Result<U128, MathError>;
    add(v0: U128, v1: U32): Result<U128, MathError>;
    add(v0: U128, v1: U64): Result<U128, MathError>;
    add(v0: U128, v1: U128): Result<U128, MathError>;
    add(v0: U128, v1: U256): Result<U256, MathError>;
    add(v0: U256, v1: U): Result<U, MathError>;
    add(v0: U256, v1: U8): Result<U256, MathError>;
    add(v0: U256, v1: U16): Result<U256, MathError>;
    add(v0: U256, v1: U32): Result<U256, MathError>;
    add(v0: U256, v1: U64): Result<U256, MathError>;
    add(v0: U256, v1: U128): Result<U256, MathError>;
    add(v0: U256, v1: U256): Result<U256, MathError>;
    add(v0: number, v1: number): Result<number, MathError>;
    add(v0: bigint, v1: bigint): Result<bigint, MathError>;
    sub(v0: Float, v1: Float): Result<Float, MathError>;
    sub(v0: I, v1: I): Result<I, MathError>;
    sub(v0: I, v1: I8): Result<I, MathError>;
    sub(v0: I, v1: I16): Result<I, MathError>;
    sub(v0: I, V1: I32): Result<I, MathError>;
    sub(v0: I, v1: I64): Result<I, MathError>;
    sub(v0: I, v1: I128): Result<I, MathError>;
    sub(v0: I, v1: I256): Result<I, MathError>;
    sub(v0: I8, v1: I): Result<I, MathError>;
    sub(v0: I8, v1: I8): Result<I8, MathError>;
    sub(v0: I8, v1: I16): Result<I16, MathError>;
    sub(v0: I8, v1: I32): Result<I32, MathError>;
    sub(v0: I8, v1: I64): Result<I64, MathError>;
    sub(v0: I8, v1: I128): Result<I128, MathError>;
    sub(v0: I8, v1: I256): Result<I256, MathError>;
    sub(v0: I16, v1: I): Result<I, MathError>;
    sub(v0: I16, v1: I8): Result<I16, MathError>;
    sub(v0: I16, v1: I16): Result<I16, MathError>;
    sub(v0: I16, v1: I32): Result<I32, MathError>;
    sub(v0: I16, v1: I64): Result<I64, MathError>;
    sub(v0: I16, v1: I128): Result<I128, MathError>;
    sub(v0: I16, v1: I256): Result<I256, MathError>;
    sub(v0: I32, v1: I): Result<I, MathError>;
    sub(v0: I32, v1: I8): Result<I32, MathError>;
    sub(v0: I32, v1: I16): Result<I32, MathError>;
    sub(v0: I32, v1: I32): Result<I32, MathError>;
    sub(v0: I32, v1: I64): Result<I64, MathError>;
    sub(v0: I32, v1: I128): Result<I128, MathError>;
    sub(v0: I32, v1: I256): Result<I256, MathError>;
    sub(v0: I64, v1: I): Result<I, MathError>;
    sub(v0: I64, v1: I8): Result<I64, MathError>;
    sub(v0: I64, v1: I16): Result<I64, MathError>;
    sub(v0: I64, v1: I32): Result<I64, MathError>;
    sub(v0: I64, v1: I64): Result<I64, MathError>;
    sub(v0: I64, v1: I128): Result<I128, MathError>;
    sub(v0: I64, v1: I256): Result<I256, MathError>;
    sub(v0: I128, v1: I): Result<I, MathError>;
    sub(v0: I128, v1: I8): Result<I128, MathError>;
    sub(v0: I128, v1: I32): Result<I128, MathError>;
    sub(v0: I128, v1: I64): Result<I128, MathError>;
    sub(v0: I128, v1: I128): Result<I128, MathError>;
    sub(v0: I128, v1: I256): Result<I256, MathError>;
    sub(v0: I256, v1: I): Result<I, MathError>;
    sub(v0: I256, v1: I8): Result<I256, MathError>;
    sub(v0: I256, v1: I16): Result<I256, MathError>;
    sub(v0: I256, v1: I32): Result<I256, MathError>;
    sub(v0: I256, v1: I64): Result<I256, MathError>;
    sub(v0: I256, v1: I128): Result<I256, MathError>;
    sub(v0: I256, v1: I256): Result<I256, MathError>;
    sub(v0: U, v1: U): Result<U, MathError>;
    sub(v0: U, v1: U8): Result<U, MathError>;
    sub(v0: U, v1: U16): Result<U, MathError>;
    sub(v0: U, v1: U32): Result<U, MathError>;
    sub(v0: U, v1: U64): Result<U, MathError>;
    sub(v0: U, v1: U128): Result<U, MathError>;
    sub(v0: U, v1: U256): Result<U, MathError>;
    sub(v0: U8, v1: U): Result<U, MathError>;
    sub(v0: U8, v1: U8): Result<U8, MathError>;
    sub(v0: U8, v1: U16): Result<U16, MathError>;
    sub(v0: U8, v1: U32): Result<U32, MathError>;
    sub(v0: U8, v1: U64): Result<U64, MathError>;
    sub(v0: U8, v1: U128): Result<U128, MathError>;
    sub(v0: U8, v1: U256): Result<U256, MathError>;
    sub(v0: U16, v1: U): Result<U, MathError>;
    sub(v0: U16, v1: U8): Result<U16, MathError>;
    sub(v0: U16, v1: U16): Result<U16, MathError>;
    sub(v0: U16, v1: U32): Result<U32, MathError>;
    sub(v0: U16, v1: U64): Result<U64, MathError>;
    sub(v0: U16, v1: U128): Result<U128, MathError>;
    sub(v0: U16, v1: U256): Result<U256, MathError>;
    sub(v0: U32, v1: U): Result<U, MathError>;
    sub(v0: U32, v1: U8): Result<U32, MathError>;
    sub(v0: U32, v1: U32): Result<U32, MathError>;
    sub(v0: U32, v1: U64): Result<U64, MathError>;
    sub(v0: U32, v1: U128): Result<U128, MathError>;
    sub(v0: U32, v1: U256): Result<U256, MathError>;
    sub(v0: U64, v1: U): Result<U, MathError>;
    sub(v0: U64, v1: U8): Result<U64, MathError>;
    sub(v0: U64, v1: U16): Result<U64, MathError>;
    sub(v0: U64, v1: U32): Result<U64, MathError>;
    sub(v0: U64, v1: U64): Result<U64, MathError>;
    sub(v0: U64, v1: U128): Result<U128, MathError>;
    sub(v0: U64, v1: U256): Result<U256, MathError>;
    sub(v0: U128, v1: U): Result<U, MathError>;
    sub(v0: U128, v1: U8): Result<U128, MathError>;
    sub(v0: U128, v1: U16): Result<U128, MathError>;
    sub(v0: U128, v1: U32): Result<U128, MathError>;
    sub(v0: U128, v1: U64): Result<U128, MathError>;
    sub(v0: U128, v1: U128): Result<U128, MathError>;
    sub(v0: U128, v1: U256): Result<U256, MathError>;
    sub(v0: U256, v1: U): Result<U, MathError>;
    sub(v0: U256, v1: U8): Result<U256, MathError>;
    sub(v0: U256, v1: U16): Result<U256, MathError>;
    sub(v0: U256, v1: U32): Result<U256, MathError>;
    sub(v0: U256, v1: U64): Result<U256, MathError>;
    sub(v0: U256, v1: U128): Result<U256, MathError>;
    sub(v0: U256, v1: U256): Result<U256, MathError>;
    sub(v0: number, v1: number): Result<number, MathError>;
    sub(v0: bigint, v1: bigint): Result<bigint, MathError>;
    mul(v0: Float, v1: Float): Result<Float, MathError>;
    mul(v0: I, v1: I): Result<I, MathError>;
    mul(v0: I, v1: I8): Result<I, MathError>;
    mul(v0: I, v1: I16): Result<I, MathError>;
    mul(v0: I, V1: I32): Result<I, MathError>;
    mul(v0: I, v1: I64): Result<I, MathError>;
    mul(v0: I, v1: I128): Result<I, MathError>;
    mul(v0: I, v1: I256): Result<I, MathError>;
    mul(v0: I8, v1: I): Result<I, MathError>;
    mul(v0: I8, v1: I8): Result<I8, MathError>;
    mul(v0: I8, v1: I16): Result<I16, MathError>;
    mul(v0: I8, v1: I32): Result<I32, MathError>;
    mul(v0: I8, v1: I64): Result<I64, MathError>;
    mul(v0: I8, v1: I128): Result<I128, MathError>;
    mul(v0: I8, v1: I256): Result<I256, MathError>;
    mul(v0: I16, v1: I): Result<I, MathError>;
    mul(v0: I16, v1: I8): Result<I16, MathError>;
    mul(v0: I16, v1: I16): Result<I16, MathError>;
    mul(v0: I16, v1: I32): Result<I32, MathError>;
    mul(v0: I16, v1: I64): Result<I64, MathError>;
    mul(v0: I16, v1: I128): Result<I128, MathError>;
    mul(v0: I16, v1: I256): Result<I256, MathError>;
    mul(v0: I32, v1: I): Result<I, MathError>;
    mul(v0: I32, v1: I8): Result<I32, MathError>;
    mul(v0: I32, v1: I16): Result<I32, MathError>;
    mul(v0: I32, v1: I32): Result<I32, MathError>;
    mul(v0: I32, v1: I64): Result<I64, MathError>;
    mul(v0: I32, v1: I128): Result<I128, MathError>;
    mul(v0: I32, v1: I256): Result<I256, MathError>;
    mul(v0: I64, v1: I): Result<I, MathError>;
    mul(v0: I64, v1: I8): Result<I64, MathError>;
    mul(v0: I64, v1: I16): Result<I64, MathError>;
    mul(v0: I64, v1: I32): Result<I64, MathError>;
    mul(v0: I64, v1: I64): Result<I64, MathError>;
    mul(v0: I64, v1: I128): Result<I128, MathError>;
    mul(v0: I64, v1: I256): Result<I256, MathError>;
    mul(v0: I128, v1: I): Result<I, MathError>;
    mul(v0: I128, v1: I8): Result<I128, MathError>;
    mul(v0: I128, v1: I32): Result<I128, MathError>;
    mul(v0: I128, v1: I64): Result<I128, MathError>;
    mul(v0: I128, v1: I128): Result<I128, MathError>;
    mul(v0: I128, v1: I256): Result<I256, MathError>;
    mul(v0: I256, v1: I): Result<I, MathError>;
    mul(v0: I256, v1: I8): Result<I256, MathError>;
    mul(v0: I256, v1: I16): Result<I256, MathError>;
    mul(v0: I256, v1: I32): Result<I256, MathError>;
    mul(v0: I256, v1: I64): Result<I256, MathError>;
    mul(v0: I256, v1: I128): Result<I256, MathError>;
    mul(v0: I256, v1: I256): Result<I256, MathError>;
    mul(v0: U, v1: U): Result<U, MathError>;
    mul(v0: U, v1: U8): Result<U, MathError>;
    mul(v0: U, v1: U16): Result<U, MathError>;
    mul(v0: U, v1: U32): Result<U, MathError>;
    mul(v0: U, v1: U64): Result<U, MathError>;
    mul(v0: U, v1: U128): Result<U, MathError>;
    mul(v0: U, v1: U256): Result<U, MathError>;
    mul(v0: U8, v1: U): Result<U, MathError>;
    mul(v0: U8, v1: U8): Result<U8, MathError>;
    mul(v0: U8, v1: U16): Result<U16, MathError>;
    mul(v0: U8, v1: U32): Result<U32, MathError>;
    mul(v0: U8, v1: U64): Result<U64, MathError>;
    mul(v0: U8, v1: U128): Result<U128, MathError>;
    mul(v0: U8, v1: U256): Result<U256, MathError>;
    mul(v0: U16, v1: U): Result<U, MathError>;
    mul(v0: U16, v1: U8): Result<U16, MathError>;
    mul(v0: U16, v1: U16): Result<U16, MathError>;
    mul(v0: U16, v1: U32): Result<U32, MathError>;
    mul(v0: U16, v1: U64): Result<U64, MathError>;
    mul(v0: U16, v1: U128): Result<U128, MathError>;
    mul(v0: U16, v1: U256): Result<U256, MathError>;
    mul(v0: U32, v1: U): Result<U, MathError>;
    mul(v0: U32, v1: U8): Result<U32, MathError>;
    mul(v0: U32, v1: U32): Result<U32, MathError>;
    mul(v0: U32, v1: U64): Result<U64, MathError>;
    mul(v0: U32, v1: U128): Result<U128, MathError>;
    mul(v0: U32, v1: U256): Result<U256, MathError>;
    mul(v0: U64, v1: U): Result<U, MathError>;
    mul(v0: U64, v1: U8): Result<U64, MathError>;
    mul(v0: U64, v1: U16): Result<U64, MathError>;
    mul(v0: U64, v1: U32): Result<U64, MathError>;
    mul(v0: U64, v1: U64): Result<U64, MathError>;
    mul(v0: U64, v1: U128): Result<U128, MathError>;
    mul(v0: U64, v1: U256): Result<U256, MathError>;
    mul(v0: U128, v1: U): Result<U, MathError>;
    mul(v0: U128, v1: U8): Result<U128, MathError>;
    mul(v0: U128, v1: U16): Result<U128, MathError>;
    mul(v0: U128, v1: U32): Result<U128, MathError>;
    mul(v0: U128, v1: U64): Result<U128, MathError>;
    mul(v0: U128, v1: U128): Result<U128, MathError>;
    mul(v0: U128, v1: U256): Result<U256, MathError>;
    mul(v0: U256, v1: U): Result<U, MathError>;
    mul(v0: U256, v1: U8): Result<U256, MathError>;
    mul(v0: U256, v1: U16): Result<U256, MathError>;
    mul(v0: U256, v1: U32): Result<U256, MathError>;
    mul(v0: U256, v1: U64): Result<U256, MathError>;
    mul(v0: U256, v1: U128): Result<U256, MathError>;
    mul(v0: U256, v1: U256): Result<U256, MathError>;
    mul(v0: number, v1: number): Result<number, MathError>;
    mul(v0: bigint, v1: bigint): Result<bigint, MathError>;
};