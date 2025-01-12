import type { SomeValOf } from "@core";
import type { Option } from "@core";
import { Some } from "@core";

export type SomeValOfAll<T1 extends Array<Option<unknown>>> = {
    [T2 in keyof T1]: T1[T2] extends Some<unknown> ? SomeValOf<T1[T2]> : never
};