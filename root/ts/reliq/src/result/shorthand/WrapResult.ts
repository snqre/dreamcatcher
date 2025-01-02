import type { Function } from "@root";
import { Result } from "@root";

export function wrapResult<T, E = unknown>(op: Function<void, T>): Result<T, E> {
    return Result.wrap(op);
}