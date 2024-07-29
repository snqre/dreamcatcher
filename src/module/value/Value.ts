import {EventEmitter} from "fbemitter";
import {EventSubscription} from "fbemitter";

type OnSetHook<T> = (newValue: T, oldValue: T) => unknown;

interface Value<T> {
    set(value: T): void;
    onSet(hook: OnSetHook<T>): EventSubscription;
}

class Value<T> {
    private readonly _em: EventEmitter = new EventEmitter();
    public constructor(private _stored: T) {}

    public get(): T {
        return this._stored;
    }

    public set(value: T): void {
        let newValue: T = value;
        let oldValue: T = this._stored;
        this._em.emit("set", newValue, oldValue);
        return;
    }

    public onSet(hook: OnSetHook<T>): EventSubscription {
        return this._em.addListener("set", hook);
    }
}

export type {OnSetHook};
export {Value};