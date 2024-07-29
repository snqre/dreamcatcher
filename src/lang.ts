import * as Fb from "fbemitter";

/// Lang exports key functionality

class _Bus {
    private constructor() {}
    private static _questionChannels: Map<string, undefined | Fb.EventEmitter> = new Map();
    private static _responseChannels: Map<string, undefined | Fb.EventEmitter> = new Map();
    
    public static questionChannels(id: string): Fb.EventEmitter {
        if (!this._questionChannels.get(id)) {
            return this._questionChannels
                .set(id, new Fb.EventEmitter())
                .get(id)!;
        }
        return this._questionChannels.get(id)!;
    }

    public static responseChannels(id: string): Fb.EventEmitter {
        if (!this._responseChannels.get(id)) {
            return this._responseChannels
                .set(id, new Fb.EventEmitter())
                .get(id)!;
        }
        return this._responseChannels.get(id)!;
    }
}

interface Log {
    timestamp(): bigint;
    item():
        | string
        | Event;
}

class Log implements Log {
    public constructor(
        private _timestamp: bigint,
        private _item:
            | string
            | Event
    ) {}
}

class Logs {
    private static _logs: Log[];

    private constructor() {}

    public static add(log: Event) {
        let timestamp = Date.now();
        this._logs.push(new Log(BigInt(timestamp), log));
    }
}

class Event {
    public constructor(
        private _from: string,
        private _signature: string,
        private _item?: unknown
    ) {
        Logs.add(this);
    }

    public from(): string {
        return this._from;
    }

    public signature(): string {
        return this._signature;
    }

    public item(): readonly [unknown] {
        return [this._item];
    }
}

export { Event };

export { Ok } from "ts-results";
export { Err } from "ts-results";
export { Option } from "ts-results";
export { Some } from "ts-results";
export { None } from "ts-results";