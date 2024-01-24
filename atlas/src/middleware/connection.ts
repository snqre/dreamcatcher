import * as express from "express";
import * as http from "http";

export interface Connection {
  socket: () => express.Application;
  server: () => http.Server;
  port: () => number;
  router: () => express.Router;
  cache: (position?: number) => Array<any> | any;
  cacheIsEnabled: () => boolean;
  setPort: (port: number) => Connection;
  openPathOut: (path: string, callback: (request: express.Request, response: express.Response) => void) => Connection;
  openPathIn: (path: string, callback: (request: express.Request, response: express.Response) => void) => Connection;
  closePathOut: (path: string) => Connection;
  closePathIn: (path: string) => Connection;
  openTimedPathOut: (path: string, wait: number, callback: (request: express.Request, response: express.Response) => void) => Connection;
  openTimedPathIn: (path: string, wait: number, callback: (request: express.Request, response: express.Response) => void) => Connection;
  connect: () => Connection;
  disconnect: () => Connection;
  reconnect: (port: number) => Connection;
  request: <T>(url: string) => Promise<T>;
  post: <T>(url: string, data: any) => Promise<T>;
  enableCache: () => Connection;
  disableCache: () => Connection;
}

export const connection: () => Connection = ((): () => Connection => {
  let instance: Connection;

  const blueprint = (): Connection => {
    let myServer: http.Server;
    let myPort: number;
    let myRouter: express.Router;
    let myCache: Array<any>;
    let myCacheIsEnabled: boolean;

    const socket = (): express.Application => {
      return express.application;
    }

    const server = (): http.Server => {
      return myServer;
    }

    const port = (): number => {
      return myPort;
    }

    const router = (): express.Router => {
      return myRouter;
    }

    const cache = (position?: number): Array<any> | any => {
      let wasNotGivenPosition = position === undefined;
      if (wasNotGivenPosition) {
        return myCache;
      }
      /// position cannot be undefined at this stage but we must the compiler will throwing a tantrum if i dont do this
      return myCache[position === undefined ? 0 : position];
    }

    const cacheIsEnabled = (): boolean => {
      return myCacheIsEnabled;
    }

    const setPort = (port: number): typeof instance => {
      myPort = port;
      return instance;
    }

    const openPathOut = (path: string, callback: (request: express.Request, response: express.Response) => void): typeof instance => {
      socket()["get"](path, callback);
      return instance;
    }

    const openPathIn = (path: string, callback: (request: express.Request, response: express.Response) => void): typeof instance => {
      socket()["post"](path, callback);
      return instance;
    }

    const closePathOut = (path: string): typeof instance => {
      return _closePath("get", path);
    }

    const closePathIn = (path: string): typeof instance => {
      return _closePath("post", path);
    }

    const openTimedPathOut = (path: string, wait: number, callback: (request: express.Request, response: express.Response) => void): typeof instance => {
      openPathOut(path, callback);
      setTimeout(function(): void {
        closePathOut(path);
      });
      return instance;
    }

    const openTimedPathIn = (path: string, wait: number, callback: (request: express.Request, response: express.Response) => void): typeof instance => {
      openPathIn(path, callback);
      setTimeout((): void => {
        closePathIn(path);
      });
      return instance;
    }

    const connect = (): typeof instance => {
      myServer = socket().listen(port(), (): void => {
        console.log(`connectt => http://localhost:${port()}`);
      });
      socket().use((request: express.Request, response: express.Response, next: Function): void => {
        let host = `${request.protocol}://${request.get("host")}${request.originalUrl}`;
        console.log(`host detected => ${host}`);
        if (cacheIsEnabled()) {
          myCache.push({
            req: request,
            res: response
          });
        }
        next();
      });
      return instance;
    }

    const disconnect = (): typeof instance => {
      if (server()) {
        myServer.close((): void => {
          console.log(`disconnect => http://${(server().address() as any).address as string}:${port()}`);
        });
      }
      return instance;
    }

    const reconnect = (port: number): typeof instance => {
      disconnect();
      setPort(port);
      connect();
      return instance;
    }

    const request = <T>(url: string): Promise<T> => {
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

    const post = <T>(url: string, data: any): Promise<T> => {
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

    const enableCache = (): typeof instance => {
      myCacheIsEnabled = true;
      return instance;
    }

    const disableCache = (): typeof instance => {
      myCacheIsEnabled = false;
      return instance;
    }

    const _closePath = (method: string, path: string): typeof instance => {
      if (socket()._router.stack.find((layer: any): boolean => { return layer.route?.path === path && layer.route?.methods[method] === true; })) {
        socket()._router.stack = socket()._router.stack.filter((layer: any): any => layer !== socket()._router.stack.find((layer: any): boolean => { return layer.route?.path === path && layer.route?.methods[method] === true; }));
      }
      return instance!;
    }

    return {
      socket,
      server,
      port,
      router,
      cache,
      cacheIsEnabled,
      setPort,
      openPathOut,
      openPathIn,
      closePathOut,
      closePathIn,
      openTimedPathOut,
      openTimedPathIn,
      connect,
      disconnect,
      reconnect,
      request,
      post,
      enableCache,
      disableCache
    };
  }

  return (): Connection => {
    if (!instance) {
      instance = blueprint();
    }
    return instance;
  };
})();

