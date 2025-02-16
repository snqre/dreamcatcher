import {none} from "->common";

export function some<T, X extends Array<T>>(item: X): boolean;
export function some<T>(item: T): boolean;
export function some<T>(item: T): boolean {
    return !none(item);
}