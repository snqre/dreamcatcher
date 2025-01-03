import type { Function } from "@root";
import type { Option } from "@root";
import { None } from "@root";
import { Ok } from "@root";
import { toString as toString_ } from "@root";

export type Some<T1> = {
    some(): this is Some<T1>;
    none(): this is None;
    val(): T1;
    expect(__: unknown): T1;
    unwrap(): T1;
    unwrapOr(__: unknown): T1;
    unwrapSafely(): T1;
    andThen<T2>(op: Function<T1, Option<T2>>): Option<T2>;
    map<T2>(op: Function<T1, T2>): Some<T2>;
    toResult<T2>(__: T2): Ok<T1>;
    toString(): string;
};

export function Some<T1>(_v: T1): Some<T1> {
    /** @constructor */ {
        return { 
            some, 
            none, 
            val, 
            expect, 
            unwrap, 
            unwrapOr,
            unwrapSafely,
            andThen,
            map,
            toResult,
            toString
        };
    }

    function some(): this is Some<T1> {
        return true;
    }

    function none(): this is None {
        return false;
    }

    function val(): T1 {
        return _v;
    }

    function expect(__: unknown): T1 {
        return val();
    }

    function unwrap(): T1 {
        return val();
    }

    function unwrapOr(__: unknown): T1 {
        return val();
    }

    function unwrapSafely(): T1 {
        return val();
    }

    function andThen<T2>(op: Function<T1, Option<T2>>): Option<T2> {
        return op(val());
    }

    function map<T2>(op: Function<T1, T2>): Some<T2> {
        return Some(op(val()));
    }

    function toResult<T2>(__: T2): Ok<T1> {
        return Ok(val());
    }

    function toString(): ReturnType<Some<T1>["toString"]> {
        return `Some(${ toString_(val()) })`;
    }
}