import * as express from "express";
import * as https from "https";
import * as http from "http";
import * as fs from "fs";

const sock = (function() {
  return function() {
    return {
      x: 2
    }
  }
})()



const socket: () => { socket: <T extends (...args: any[]) => any>(mod: T) => any; } = (() => {
  return (): any => {
    const socket = <T extends (...args: any[]) => any>(mod: T): any => {
      let _instance: any;

      const instance = (): any => {
        return mod();
      }

      return ((): any => {
        return _instance = instance();
      })();
    }

    return {
      socket
    };
  };
})();

interface Connection {
  socket: () => express.Express;

  server: () => http.Server | https.Server;

  port: () => number;

  router: () => express.Router;

  privateKeyFile: () => Buffer;

  certificateFile: () => Buffer;

  cache: () => Array<object>;

  readCache: (position: number) => object;

  cacheIsEnabled: () => boolean;

  importSocket: () => this;

  setPort: (port: number) => this;

  importHttpsPrivateKeyFile: (pmsFilePath: string) => this;

  importHttpsCertificateFile: (pmsFilePath: string) => this;

  openPathOut: (path: string, callback: (request: express.Request, response: express.Response) => void) => this;

  openPathIn: (path: string, callback: (request: express.Request, response: express.Response) => void) => this;

  closePathOut: (path: string) => this;

  closePathIn: (path: string) => this;

  openTimedPathOut: (path: string, wait: number,callback: (request: express.Request, response: express.Response) => void) => this;

  openTimedPathIn: (path: string, wait: number, callback: (request: express.Request, response: express.Response) => void) => this;

  connect: () => this;

  safeConnect: () => this;

  disconnect:() => this;

  reconnect: (port: number) => this;

  safeReconnect: (port: number) => this;

  request: <T>(url: string) => Promise<T>;

  post: <T>(url: string, data: object) => Promise<T>;

  enableCache: () => this;

  disableCache: () => this;
}

let connectionSingleton: Connection | null = null;

const connection: () => Connection = (function(): any {
  return socket()
    .socket(function(): Connection {
      let _socket: any;
      let _server: http.Server | https.Server;
      let _port: number;
      let _router: express.Router;
      let _privateKeyFile: Buffer;
      let _certificateFile: Buffer;
      let _cache: Array<object>;
      let _cacheIsEnabled: boolean;

      const socket = function(): express.Express {
        return _socket;
      }
  
      const server = function(): http.Server | https.Server {
        return _server;
      }
  
      const port = function(): number {
        return _port;
      }
  
      const router = function(): express.Router {
        return _router;
      }
  
      const privateKeyFile = function(): Buffer {
        return _privateKeyFile;
      }
  
      const certificateFile = function(): Buffer {
        return _certificateFile;
      }
  
      const cache = function(): Array<object> {
        return _cache;
      }
  
      const readCache = function(position: number): object {
        return _cache[position];
      }
  
      const cacheIsEnabled = function(): boolean {
        return _cacheIsEnabled;
      }
  
      const importSocket = function(): any {
        _socket = express();
        return this;
      }
  
      const setPort = function(port: number): any {
        _port = port;
        return this;
      }
  
      const importHttpsPrivateKeyFile = function(pmsFilePath: string): any {
        _privateKeyFile = fs.readFileSync(pmsFilePath);
        return this;
      }
  
      const importHttpsCertificateFile = function(pmsFilePath: string): any {
        _certificateFile = fs.readFileSync(pmsFilePath);
        return this;
      }
  
      const openPathOut = function(path: string, callback: (request: express.Request, response: express.Response) => void): any {
        _socket["get"](path, callback);
        return this;
      }
  
      const openPathIn = function(path: string, callback: (request: express.Request, response: express.Response) => void): any {
        _socket["post"](path, callback);
        return this;
      }
  
      const closePathOut = function(path: string): any {
        return _closePath("get", path);  /// returns this
      }
  
      const closePathIn = function(path: string): any {
        return _closePath("post", path); /// returns this
      }
  
      const openTimedPathOut = function(path: string, wait: number, callback: (request: express.Request, response: express.Response) => void): any {
        openPathOut(path, callback);
        setTimeout(() => {
          closePathOut(path);
        }, wait);
        return this;
      }
  
      const openTimedPathIn = function(path: string, wait: number, callback: (request: express.Request, response: express.Response) => void): any {
        openPathIn(path, callback);
        setTimeout(() => {
          closePathIn(path);
        }, wait);
        return this;
      }
  
      const connect = function(): any {
        _server = _socket.listen(port(), (): void => {
          console.log(`connect => http://localhost:${port()}`);
        });
        _socket.use((request: express.Request, response: express.Response, next: Function): void => {
          let host = `${request.protocol}://${request.get("host")}${request.originalUrl}`;
          console.log(`host detected => ${host}`);
          if (cacheIsEnabled()) {
            _cache.push({
              condition: "REQUEST",
              content: request
            });
            _cache.push({
              condition: "RESPONSE",
              content: response
            });
          }
          next();
        });
        return this;
      }
  
      const safeConnect = function(): any {
        _server = https.createServer({
          key: privateKeyFile(),
          cert: certificateFile()
        }, socket());
        _server.listen(port(), (): void => {
          console.log(`safe connect => https://localhost:${port()}`);
        });
        _socket.use((request: express.Request, response: express.Response, next: Function): void => {
          let host = `${request.protocol}://${request.get("host")}${request.originalUrl}`;
          console.log(`host detected => ${host}`);
          if (cacheIsEnabled()) {
            _cache.push({
              condition: "REQUEST",
              content: request
            });
            _cache.push({
              condition: "RESPONSE",
              content: response
            });
          }
          next();
        });
        return this;
      }
  
      const disconnect = function(): any {
        if (server()) {
          _server.close((): void => {
            let protocol: string = server() instanceof https.Server ? "https" : "http";
            let address: any = _server.address();
            if (address && typeof address !== "string") {
              let domain = (address as any).address as string;
              console.log(`disconnect => ${protocol}://${domain}:${port()}`);
            }
            else {
              throw new Error("unable to disconnect due to invalid server address type");
            }
          });
        }
        return this;
      }
  
      const reconnect = function(port: number): any {
        disconnect();
        setPort(port);
        connect();
        return this;
      }
  
      const safeReconnect = function(port: number): any {
        disconnect();
        setPort(port);
        safeConnect();
        return this;
      }
  
      const request = function<T>(url: string): Promise<T> {
        return new Promise<T>((resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void): any => {
          fetch(url)
            .then(response => {
              if (!response.ok) {
                throw new Error(`failed request with status => ${response.status}`);
              }
              return response.json() as Promise<T>;
            })
            .then(data => {
              resolve(data);
            })
            .catch(error => {
              reject(error);
            });
        });
      }
  
      const post = function<T>(url: string, data: object): Promise<T> {
        return new Promise<T>((resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void) => {
          fetch(url)
            .then(response => {
              if (!response.ok) {
                throw new Error(`post failed with status => ${response.status}`);
              }
              return response.json() as Promise<T>;
            })
            .then(data => {
              resolve(data);
            })
            .catch(error => {
              reject(error);
            });
        });
      }
  
      const enableCache = function(): any {
        _cacheIsEnabled = true;
        return this;
      }
  
      const disableCache = function(): any {
        _cacheIsEnabled = false;
        return this;
      }
  
      const _closePath = function(method: string, path: string): any {
        let route = _socket._router.stack.find((layer: any): boolean => {
          return layer.route?.path === path && layer.route?.methods[method] === true;
        });
        if (route) {
          _socket._router.stack = _socket._router.stack.filter((layer: any): any => layer !== route);
        }
        return this;
      }

      connectionSingleton = {
        socket,
        server,
        port,
        router,
        privateKeyFile,
        certificateFile,
        cache,
        readCache,
        cacheIsEnabled,
        importSocket,
        setPort,
        importHttpsPrivateKeyFile,
        importHttpsCertificateFile,
        openPathOut,
        openPathIn,
        closePathOut,
        closePathIn,
        openTimedPathOut,
        openTimedPathIn,
        connect,
        safeConnect,
        disconnect,
        reconnect,
        safeReconnect,
        request,
        post,
        enableCache,
        disableCache
      }

      return connectionSingleton;
    });
});

interface Authenticator {
  seed: () => string;
}

const authenticator: () => Authenticator = (function(): any {
  return socket()
    .socket(function(): Authenticator {
      let _seed: string;

      const seed = function(): string {
        return _seed;
      }

      return {
        seed
      };
    });
});

interface Block {

}

const block = function() {
  let _message: string;

  return {
    
  }
}

interface Stream {
  chain: () => Array<object>;
}

const stream: () => Stream = (function(): any {
  return socket()
    .socket(function(): Stream {
      let _chain: Array<object>;

      const chain = function(): Array<object> {
        return _chain;
      }

      return {
        chain
      };
    });
});




console.log(
  connection()
    .importSocket()
    .setPort(2000)
    .port()
);

console.log(connection().port())
