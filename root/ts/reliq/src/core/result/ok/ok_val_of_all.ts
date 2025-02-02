import type { OkValOf } from "@core";
import type { Result } from "@core";

export type OkValOfAll<T1 extends Array<Result<unknown, unknown>>> = {
    [T2 in keyof T1]: OkValOf<T1[T2]>;
};