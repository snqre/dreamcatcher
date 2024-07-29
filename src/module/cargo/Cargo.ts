import {EventEmitter} from "fbemitter";
import {EventSubscription} from "fbemitter";

class Config {
    public readonly verbose: boolean;
    public readonly verboseAddress: string[] = [];
    public constructor({
        verbose=false,
        verboseAddress=[],}:{
            verbose?: boolean,
            verboseAddress?: string[],
        }) {
            this.verbose = verbose;
        }
}

class Cargo {
    private constructor() {}
    private static _em: EventEmitter = new EventEmitter();
    private static _config: Config = new Config({
        verbose: false,
        verboseAddress: []
    });

    public static Config = Config;

    public static config(config: Config): typeof Cargo {
        this._config = config;
        return Cargo;
    }

    public static declare(address: string) {
        return class _ {
            public static _subscriptions: EventSubscription[] = [];

            public static ship(address: string, type: string, item?: unknown): typeof _ {
                Cargo._em.emit(`${address}::${type}`, item);
                Cargo._tryLog(`ship::${address}::${type}::${item}`);
                return _;
            }

            public static shipHere(type: string, item?: unknown): typeof _ {
                Cargo._em.emit(`${address}::${type}`, item);
                Cargo._tryLog(`ship::${address}::${type}::${item}`);
                return _;
            }

            public static dock(type: string, listener: (item?: unknown) => unknown, once?: boolean): typeof _ {
                _._subscriptions.push(
                    !once
                        ? Cargo._em.addListener(`${address}::${type}`, listener)
                        : Cargo._em.once(`${address}::${type}`, listener)
                );
                Cargo._tryLog(`dock::${address}::${type}`);
                return _;
            }

            public static eof(): () => void {
                return () => _._subscriptions.forEach(subscription => subscription.remove());
            }
        }
    }

    protected static _tryLog(message: string): void {
        if (Cargo._config.verbose) {
            return console.log(message);
        }
        return;
    }
}

export {Cargo};