import { Ok } from "ts-results";
import { Err } from "ts-results";

type Func = (...args: any) => any;

/**
 * Type alias `ErrCodeReturn` extracts the error code type from the return type of a function.
 * If the return type of the function is an `Err` with an error code of type `ErrCode`,
 * it will return `Err<ErrCode>`. Otherwise, it will return `never`.
 * 
 * The error code must extend a `string`.
 * 
 * @template FunctionReturnType - The return type of the function.
 */
type ErrCodeReturn<FunctionReturnType> = FunctionReturnType extends Err<infer ErrCode extends string> ? Err<ErrCode> : never;

/**
 * Type alias `ErrCode` extracts the error code type from the return type of a given function `Function`.
 * It uses `ErrCodeReturn` to determine the error code type.
 * 
 * @template Function - The function whose return type's error code is being extracted.
 */
type ErrCode<Function extends Func> = ErrCodeReturn<ReturnType<Function>>;

/**
 * Type alias `ContentReturn` extracts the content type from the return type of a function.
 * If the return type of the function is an `Ok` with content of type `Content`,
 * it will return `Ok<Content>`. Otherwise, it will return `never`.
 * 
 * @template FunctionReturnType - The return type of the function.
 */
type ContentReturn<FunctionReturnType> = FunctionReturnType extends Ok<infer Content> ? Ok<Content> : never;

/**
 * Type alias `Content` extracts the content type from the return type of a given function `Function`.
 * It uses `ContentReturn` to determine the content type.
 * 
 * @template Function - The function whose return type's content is being extracted.
 */
type Content<Function extends Func> = ContentReturn<ReturnType<Function>>;

export type { ErrCodeReturn };
export type { ErrCode };
export type { ContentReturn };
export type { Content };