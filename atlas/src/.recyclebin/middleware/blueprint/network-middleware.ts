import {
  application,
  Application,
  Router,
  Request,
  Response
} 
from "express";

import {Server} from "http";

class ConnectionMiddleware {
  _server: Server | undefined;

  public constructor() {
    
  }

  public openPathGET() {

  }
}


export interface IConnectionMiddleware {

}

const networkMiddleware: () => IConnectionMiddleware = ((): () => IConnectionMiddleware => {
  let _instance: IConnectionMiddleware;

  const _ = (): IConnectionMiddleware => {
    let _server: Server;
    let _router: Router;
    
    const server = (): Server => _server;

    const router = (): Router => _router;

    const openPathGET = (path: string, task: (request: Request, response: Response) => void): IConnectionMiddleware => {
      application["get"](path, task);
      return _instance;
    }

    const openPathPOST = (path: string, task: (request: Request, response: Response) => void): IConnectionMiddleware => {
      application["post"](path, task);
      return _instance;
    }
    
    const closePathGET = (path: string) => {
      if (application._router.stack.find((layer: any): boolean => {
        return layer.route?.path === path && layer.route?.methods["get"] === true;
      })) {
        application._router.stack = application._router.stack.filter((layer: any): any => layer !== application._router.stack.find((layer: any): boolean => {
          return layer.route?.path === path && layer.route?.methods["get"] === true;
        }));
      }
      return _instance;
    }

    const closePathPOST = (path: string) => {
      if (application._router.stack.find((layer: any): boolean => {
        return layer.route?.path === path && layer.route?.methods["post"] === true;
      })) {
        application._router.stack = application._router.stack.filter((layer: any): any => layer !== application._router.stack.find((layer: any): boolean => {
          return layer.route?.path === path && layer.route?.methods["post"] === true;
        }));
      }
      return _instance;
    }

    const openTimedPathGET = (path: string, closeAfterMs: number, task: (request: Request, response: Response) => void): IConnectionMiddleware => {
      openPathGET(path, task);
      setTimeout((): void => {
        closePathGET(path);
      });
      return _instance;
    }

    const openTimedPathPOST = (path: string, closeAfterMs: number, task: (request: Request, response: Response) => void): IConnectionMiddleware => {
      openPathPOST(path, task);
      setTimeout((): void => {
        closePathPOST(path);
      });
      return _instance;
    }

    const connect = (port: number): IConnectionMiddleware => {
      _server = application.listen(port, (): void => {
        console.log(`connectt => http://localhost:${port}`);
      });
      return _instance;
    }

    const disconnect = (): IConnectionMiddleware => {
      if (server()) {
        _server.close((): void => {});
      }
      return _instance;
    }

    const reConnect = (port: number): IConnectionMiddleware => {
      disconnect();
      connect(port);
      return _instance;
    }

    const request = <T>(url: string): Promise<T> => {
      return new Promise<T>((resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void): any => {
        fetch(url)
          .then(response => {
            if (!response.ok) {
              throw new Error(`failed request with status ${response.status}`);
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

    const post = <T>(url: string, content: any): Promise<T> => {
      return new Promise<T>((resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void) => {
        fetch(url)
          .then(response => {
            if (!response.ok) {
              throw new Error(`post failed with status ${response.status}`);
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

    return {
      server,
      router,
      openPathGET,
      openPathPOST,
      closePathGET,
      closePathPOST,
      openTimedPathGET,
      openTimedPathPOST,
      connect,
      disconnect,
      reConnect,
      request,
      post
    }
  }
})();