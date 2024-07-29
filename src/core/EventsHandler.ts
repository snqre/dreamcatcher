/** @module */

import { EventEmitter } from "fbemitter";
import { EventSubscription } from "fbemitter";

/** @hidden @interface */
type Shared = {
    /** @reference */
    emA(at: string): EventEmitter;
    /** @reference */
    emB(at: string): EventEmitter;
};

/** @interface */
type Subscription = {
    remove(): void;
}

type HookArgs = {
    at: string;
    type: string;
    handler: (...items: unknown[]) => unknown;
    once: boolean;
};

type ReactionArgs = {
    from: string;
    type: string;
    handler: (...items: unknown[]) => unknown;
    once?: boolean;
};

type TaskArgs = {
    to: string;
    type: string;
    timeout: bigint;
    items: unknown[];
};

type EventArgs = {
    at: string;
    type: string;
    items: unknown[];
};

/** @hidden @static @impl */
const Shared = (function() {
    /** @state */
    let _instance: Shared = {
        emA,
        emB };
    let _mapA: Map<string, undefined | EventEmitter>;
    let _mapB: Map<string, undefined | EventEmitter>;
    
    /** @constructor */ {
        _mapA = new Map();
        _mapB = new Map();
    }

    /** @public @view @reference */
    function emA(at: string): EventEmitter {
        if (!_mapA.get(at))
            return _mapA
                .set(at, new EventEmitter())
                .get(at)!;
        return _mapA.get(at)!;
    }

    /** @public @view @reference */
    function emB(at: string): EventEmitter {
        if (!_mapB.get(at))
            return _mapB
                .set(at, new EventEmitter())
                .get(at)!;
        return _mapB.get(at)!;
    }

    return _instance;
})();

/** @class @impl */
function Hook(args: HookArgs): Subscription {
    let { at: __at, type: __type, handler: __handler, once: __once } = args;

    /** @state */
    let _instance: Subscription = {
        remove };
    let _subscription: EventSubscription;

    /** @constructor */ {
        _subscription = !__once 
            ? Shared.emA(__at).addListener(__type, function(...items: unknown[]): void {
                return Shared.emB(__at).emit(__type, __handler(...items));
            })
            : Shared.emA(__at).once(__type, function(...items: unknown[]): void {
                return Shared.emB(__at).emit(__type, __handler(...items));
            });
    }

    /** @public */
    function remove(): void {
        _subscription.remove();
        return;
    }

    return _instance;
}

/** @class @impl */
function Reaction(args: ReactionArgs): Subscription {
    let { from: __from, type: __type, handler: __handler, once: __once } = args;

    /** @state */
    let _instance: Subscription = {
        remove };
    let _subscription: EventSubscription;

    /** @constructor */ {
        _subscription = !__once
            ? Shared.emA(__from).addListener(__type, __handler)
            : Shared.emA(__from).once(__type, __handler);
    }

    /** @public */
    function remove(): void {
        _subscription.remove();
        return;
    }

    return _instance;
}

/** @public */
async function dispatchTask(args: TaskArgs): Promise<unknown> {
    let { to, type, timeout, items } = args;
    return new Promise(resolve => {
        let success: boolean = false;
        let subscription: EventSubscription = Shared.emB(to).once(type, (response: unknown) => {
            if (!success) {
                success = true;
                resolve(response);
                return;
            }
            return;
        });
        Shared.emA(to).emit(type, ...items);
        setTimeout(function() {
            if (!success) {
                subscription.remove();
                resolve(undefined);
                return;
            }
            return;
        }, Number(timeout));
        return;
    });
}

/** @public */
function dispatchEvent(args: EventArgs): void {
    let { at, type, items } = args;
    Shared.emA(at).emit(`e::${type}`, ...items);
    return;
}

export type { TaskArgs };
export type { EventArgs };
export type { HookArgs };
export type { ReactionArgs };
export type { Subscription };
export { dispatchTask };
export { dispatchEvent };
export { Hook };
export { Reaction };