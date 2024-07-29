import {Requirement} from "@requirement";





class uint {
    public constructor(protected _stored: bigint) {}

    public set(int: uint) {
        new Requirement(this._stored)
    }
}

let x: uint = new uint(500n);
x.set(new uint(488n));

class Array<T> {
    private _stored: T[] = [];

    public constructor() {}


    public access(i: bigint): T {
        let item: T | undefined = this._stored.at(Number(i));
        new Requirement(!!item, "");
        return item!;
    }

    public copy(): T[] {
        return [... this._stored];
    }
}

let tags: Array<string> = new Array();

tags.access(738n);


