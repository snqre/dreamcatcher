import { EventEmitter } from "fbemitter";
import { EventSubscription } from "fbemitter";
import { Ok } from "ts-results";
import { Err } from "ts-results";

type Operation<S> = (state: S, revert: (reason?: string) => void) => Promise<void>;
type OperationSync<S> = (state: S, revert: (reason?: string) => void) => void;

/** @interface */
type RevertableState<S extends Object> = {
    /** @view @copy */
    state(): S;
    /** @view @copy */
    snapshots(): S[];
    update(operation: Operation<S>):
        Promise<
            | Ok<null>
            | Err<Error>
            | Err<"voidErr">
        >;
    updateSync(operation: OperationSync<S>):
        | Ok<null>
        | Err<Error>
        | Err<"voidErr">;
    onUpdateStart(listener: (oldState: S) => unknown): EventSubscription;
    onUpdateEnd(listener: (newState: S) => unknown): EventSubscription;
    onUpdate(listener: (oldState: S, newState: S) => unknown): EventSubscription;
    onRevert(listener: (errCode: `revert::${string}`) => unknown): EventSubscription;
}

/** @class @impl */ 
function RevertableState<S extends Object>(__state: S): RevertableState<S> {
    /** @state */
    let _instance: RevertableState<S> = {
        state,
        snapshots,
        update,
        updateSync,
        onUpdateStart,
        onUpdateEnd,
        onUpdate,
        onRevert };
    let _state: S;
    let _emitter: EventEmitter;
    let _snapshots: S[];

    /** @constructor */ {   
        _state = { ... __state };
        _emitter = new EventEmitter();
        _snapshots = [state()]; 
    }

    /** @public @view @copy */ 
    function state(): S {
        return { ... _state };
    }

    /** @public @view @copy */
    function snapshots(): S[] {
        return [... _snapshots];
    }

    /** @public */ 
    async function update(operation: Operation<S>):
        Promise<
            | Ok<null>
            | Err<Error>
            | Err<"voidErr">
        > {
        let snapshot: S = { ... _state };
        try {
            _emitter.emit("updateStart", { ... snapshot });
            await operation(_state, reason => {
                throw new Error(_revertMessage(reason));
            });
            _snapshots.push({ ... _state });
            _emitter.emit("updateEnd", { ... _state });
            _emitter.emit("update", { ...snapshot, ... _state });
            return Ok<null>(null);
        }
        catch (error) {
            _state = { ... snapshot };
            if (error instanceof Error) {
                let message: string = error.message;
                let messageTokens: string[] = message.split("::");
                if (messageTokens[0] !== "revert") {
                    _emitter.emit("revert", "revert::reasonNotGiven");
                }
                else {
                    _emitter.emit("revert", message);
                }
                return Err<Error>(error);
            }
            _emitter.emit("revert", "revert::reasonNotGiven");
            return Err<"voidErr">("voidErr");
        }
    }

    /** @public */ 
    function updateSync(operation: OperationSync<S>):
        | Ok<null>
        | Err<Error>
        | Err<"voidErr"> {
        let snapshot: S = { ... _state };
        try {
            _emitter.emit("updateStart", { ... snapshot });
            operation(_state, reason => {
                throw new Error(_revertMessage(reason));
            });
            _snapshots.push({ ... _state });
            _emitter.emit("updateEnd", { ... _state });
            _emitter.emit("update", { ... snapshot, ... _state });
            return Ok<null>(null);
        }
        catch (error) {
            _state = { ... snapshot };
            if (error instanceof Error) {
                let message: string = error.message;
                let messageTokens: string[] = message.split("::");
                if (messageTokens[0] !== "revert") {
                    _emitter.emit("revert", "revert::reasonNotGiven");
                }
                else {
                    _emitter.emit("revert", message);
                }
                return Err<Error>(error);
            }
            _emitter.emit("revert", "revert::reasonNotGiven");
            return Err<"voidErr">("voidErr");
        }
    }

    /** @public */ 
    function onUpdateStart(listener: (oldState: S) => unknown): EventSubscription {
        return _emitter.addListener("updateStart", listener);
    }

    /** @public */ 
    function onUpdateEnd(listener: (newState: S) => unknown): EventSubscription {
        return _emitter.addListener("updateEnd", listener);
    }

    /** @public */ 
    function onUpdate(listener: (oldState: S, newState: S) => unknown): EventSubscription {
        return _emitter.addListener("update", listener);
    }

    /** @public */ 
    function onRevert(listener: (errCode: `revert::${ string }`) => unknown): EventSubscription {
        return _emitter.addListener("revert", listener);
    }

    /** @private @pure */ 
    function _revertMessage(reason?: string): string {
        return `revert::${ reason ?? "reasonNotGiven" }`;
    }

    return _instance;
}

export type { Operation };
export type { OperationSync };
export { RevertableState };