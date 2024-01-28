import {EventEmitter} from "events";
import fs from "fs";

export class InternalNetwork extends EventEmitter {
  private _logs: {event: string; args: any[]}[] = [];
  private _logFilePath: string = "atlas/src/internal-network/logs.json";

  public constructor() {
    super();
    this.loadLogsFromFile();
    const ORIGINAL_EMIT = this.emit;
    this.emit = function(eventName: string | symbol, ...args: any[]): boolean {
      const EVENT_LOG = { event: String(eventName), args };
      this._logs.push(EVENT_LOG);
      this.saveLogsToFile();
      console.log(`${String(eventName)}`, ...args);
      return ORIGINAL_EMIT.apply(this, [eventName, ...args]);
    }

    this.emit("INTERNAL_NETWORK::DEPLOYED");
  }

  private saveLogsToFile(): this {
    fs.writeFileSync(this._logFilePath, JSON.stringify(this._logs, null, 2));
    return this;
  }

  private loadLogsFromFile(): this {
    if (fs.existsSync(this._logFilePath)) {
      const DATA = fs.readFileSync(this._logFilePath, "utf-8");
      try {
        this._logs = JSON.parse(DATA);
      } catch (error) {
        this.emit("INTERNAL_NETWORK::FAILED_TO_LOAD_LOG_FILE", {
          error: error
        });
      }
    }
    return this;
  }

}

export const INTERNAL_NETWORK = (function() {
  let _instance: InternalNetwork;

  return function(): InternalNetwork {
    if (!_instance) {
      _instance = new InternalNetwork();
    }
    return _instance;
  }
})();