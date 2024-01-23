import * as express from "express";
import * as https from "https";
import * as http from "http";
import * as fs from "fs";
import * as socketIO from "socket.io";

const connection = (function() {
  let _instance:any;

  function build() {
    function instance(this: {
      _socket:express.Express,
      _server:http.Server|https.Server,
      _port:number,
      _router:express.Router,
      _privateKeyFile:Buffer,
      _certificateFile:Buffer,
      _startTimestamp:number,
      _hasStarted:boolean,
      _hasStopped:boolean,
      _cache:Array<any>,
      socket:()=>express.Express,
      server:()=>http.Server|https.Server
      port:()=>number,
      router:()=>express.Router,
      startTimestamp:()=>number,
      duration:()=>number,
      cache:()=>Array<any>,
      readCache:(position?:number)=>any,
      restartSocket:()=>any,
      setPort:(port:number)=>any,
      importHttpsPrivateKeyFile:(pmsFilePath:string)=>any,
      importHttpsCertificateFile:(pmsFilePath:string)=>any,
      generatePathOut:(path:string, callback:(request:express.Request, response:express.Response)=>void)=>any,
      generatePathsOut:(paths:Array<string>, callbacks:Array<(request:express.Request, response:express.Response)=>void>)=>any,
      generatePathIn:(path:string, callback:(request:express.Request, response:express.Response)=>void)=>any,
      generatePathsIn:(paths:Array<string>, callbacks:Array<(request:express.Request, response:express.Response)=>void>)=>any,
      deletePathOut:(path:string)=>any,
      deletePathsOut:(paths:Array<string>)=>any,
      deletePathIn:(path:string)=>any,
      deletePathsIn:(paths:Array<string>)=>any,
      generateTimedPathOut:(path:string, callback:(request:express.Request, response:express.Response)=>void)=>any,
      generateTimedPathsOut:(paths:Array<string>, callbacks:Array<(request:express.Request, response:express.Response)=>void>)=>any,
      generateTimedPathIn:(path:string, callback:(request:express.Request, response:express.Response)=>void)=>any,
      generateTimedPathsIn:(paths:Array<string>, callbacks:Array<(request:express.Request, response:express.Response)=>void>)=>any,
      grantEndpoint:()=>any,
      grantSecureEndpoint:()=>any,
      revokeEndpoint:()=>any,
      restartEndpoint:(port:number)=>any,
      restartWithSecureEndpoint:(port:number)=>any,
      request:<T>(url:string)=>Promise<T>,
      requests:<T>(urls:Array<string>)=>Array<Promise<T>>,
      submit:<T>(url:string, data:any)=>Promise<T>,
      submissions:<T>(urls:Array<string>)=>Array<Promise<T>>,
      injectMiddleware:(middleware:express.Handler)=>any,
      injectMiddlewareAt:(path:string,middleware:express.Handler)=>any,
      injectErrorHandler:(handler:express.ErrorRequestHandler)=>any,
      serveStaticFiles:(path:string, dir:string)=>any,
      enableCORS:()=>any,
      enableInboundRequestParsingToJson:()=>any,
      enableInboundRequestEncodedUrl:()=>any,
      enableSocketIOIntegration:(io:socketIO.Server)=>any,
      enableOutboundResponseCompression:()=>any,
      enableRateLimiting:(limit:number, wait:number)=>any,
      enableCrossSiteRequestForgeryProtection:()=>any,
      setCrossSiteRequestForegeryProtectionToken:(name:string, callback:(request:express.Request)=>string)=>any,
      enableHealthCheck:(path?:string)=>any,
      enableRequestCaching:()=>any,
      disableRequestCaching:()=>any,
      enableResponseCaching:()=>any,
      disableResponseCaching:()=>any
    }) {
      this.socket = ():express.Express => {
        return this._socket;
      }

      this.server = ():http.Server|https.Server => {
        return this._server;
      }

      this.port = ():number => {
        return this._port;
      }

      this.router = ():express.Router => {
        return this._router;
      }
      
      this.startTimestamp = ():number => {
        return this._startTimestamp;
      }

      this.duration = ():number => {
        if (this._hasStarted && !this._hasStopped) {
          return (Date.now() / 1000) - this.startTimestamp();
        }
        return 0;
      }

      this.restartSocket = ():any => {
        this._socket = express();
        return this;
      }

      this.setPort = (port:number):any => {
        this._port = port;
        /// @todo if port is different and endpoint is live then redeploy
        return this;
      }

      this.importHttpsPrivateKeyFile = (pmsFilePath:string):any => {
        this._privateKeyFile = fs.readFileSync(pmsFilePath);
        return this;
      }

      this.importHttpsCertificateFile = (pmsFilePath:string):any => {
        this._certificateFile = fs.readFileSync(pmsFilePath);
        return this;
      }

      this.generatePathOut = (path:string, callback:(request:express.Request, response:express.Response)=>void):any => {
        this._socket["get"](path, callback);
        return this;
      }

      
      
    }
    return new instance();
  }
  
  return function() {
    if (!_instance) {
      _instance = build();
    }
    return _instance;
  }
})();

connection()
  .socket()
  .server()
  .grantEndpoint()
  .revokeEndpoint()
  .enableResponseCaching()
  .enableRateLimiting()
  .grantEndpoint()
  .restartWithSecureEndpoint();

class ConnectionAlpha {
  private runtime: {
    socket:express.Express;
    server:http.Server|https.Server|null;
    port:number;
    routes:express.Router;
    https: {
      privateKeyFile:Buffer|null;
      certificateFile:Buffer|null;
    };
    sessionStartTimestampSeconds:number
  };

  constructor() {
    this.runtime = {
      socket: express(),
      server: null,
      port: Number(),
      routes: express.Router(),
      https: {
        privateKeyFile: null,
        certificateFile: null
      },
      sessionStartTimestampSeconds: Number()
    };
  }

  public socket():express.Express {
    return this.runtime.socket;
  }

  public server():http.Server|https.Server|null {
    return this.runtime.server;
  }

  public port():number {
    return this.runtime.port;
  }

  public routes():express.Router {
    return this.runtime.routes;
  }

  public sessionStartTimestampSeconds():number {
    return this.runtime.sessionStartTimestampSeconds;
  }

  public sessionDurationSeconds():number {
    if (this.runtime.sessionStartTimestampSeconds) {
      return (Date.now() / 1000) - this.sessionStartTimestampSeconds();
    }
    return 0;
  }

  public restartSocket():this {
    this.runtime.socket = express();
    return this;
  }

  public setPort(port:number):this {
    this.runtime.port = port;
    return this;
  }

  public setHttpsPrivateKeyPath(path:string):this {
    this.runtime.https.privateKeyFile = fs.readFileSync(path);
    return this;
  }

  public setHttpsCertificatePath(path:string):this {
    this.runtime.https.certificateFile = fs.readFileSync(path);
    return this;
  }

  public createPathOut(path:string, logic:(request:express.Request, response:express.Response)=>void):this {
    this.runtime.socket["get"](path, logic);
    return this;
  }

  public createPathIn(path:string, logic:(request:express.Request, response:express.Response)=>void):this {
    this.runtime.socket["post"](path, logic);
    return this;
  }

  public deletePathOut(path:string):this {
    return this._deletePath("get", path);
  }

  public deletePathIn(path:string):this {
    return this._deletePath("post", path);
  }

  public createTimedPathIn(path:string, logic:(request:express.Request, response:express.Response)=>void, duration:number):this {
    this.createPathIn(path, logic);
    setTimeout(() => {
      this.deletePathIn(path);
    }, duration);
    return this;
  }

  public createTimedPathOut(path:string, logic:(request:express.Request, response:express.Response)=>void, duration:number):this {
    this.createPathOut(path, logic);
    setTimeout(() => {
      this.deletePathOut(path);
    }, duration);
    return this;
  }  

  public grant():this {
    this.runtime.server = this.runtime.socket.listen(this.runtime.port, () => {
      console.log(`connection granted => http://localhost:${this.runtime.port}`);
    });
    this.runtime.socket.use((request:express.Request, response:express.Response, next:Function) => {
      let hostUrl = `${request.protocol}://${request.get('host')}${request.originalUrl}`;
      console.log(`request detected from: ${hostUrl}`);
      next();
    });
    this.runtime.sessionStartTimestampSeconds = Date.now() / 1000;
    return this;
  }

  public grantSecure():this {
    if (this.runtime.https.privateKeyFile === null || this.runtime.https.certificateFile === null) {
      throw new Error("unable to grand secure connection because no private key file or certificate file were detected");
    }
    this.runtime.server = https.createServer({
      key: this.runtime.https.privateKeyFile,
      cert: this.runtime.https.certificateFile
    }, this.runtime.socket);
    this.runtime.server.listen(this.runtime.port, () => {
      console.log(`secure connection granted => https://localhost:${this.runtime.port}`);
    })
    this.runtime.socket.use((request:express.Request, response:express.Response, next:Function) => {
      let hostUrl = `${request.protocol}://${request.get('host')}${request.originalUrl}`;
      console.log(`request detected from: ${hostUrl}`);
      next();
    });
    this.runtime.sessionStartTimestampSeconds = Date.now() / 1000;
    return this;
  }

  public restart(port:number):this {
    this
      .revoke()
      .setPort(port)
      .grant();
    return this;
  }

  public restartSecure(port:number):this {
    this
      .revoke()
      .setPort(port)
      .grantSecure();
    return this;
  }

  public revoke():this {
    if (this.runtime.server) {
      this.runtime.server.close(() => {
        if (this.runtime.server === null) {
          throw new Error("unable to revoke connection because server was not assigned");
        }
        let protocol = this.runtime.server instanceof https.Server ? "https" : "http";
        let address = this.runtime.server.address();
        if (address && typeof address !== "string") {
          let domain = (address as any).address as string;
          console.log(`connection revoked => ${protocol}://${domain}:${this.runtime.port}`);
        }
        else {
          throw new Error("unable to revoke connection because of invalid server address type");
        }
      });
      this.runtime.server = null;
    }
    this.runtime.sessionStartTimestampSeconds = Number();
    return this;
  }

  private _deletePath(method:string, path:string):this {
    let route = this.runtime.socket._router.stack.find((layer:any) => {
      return layer.route?.path === path && layer.route?.methods[method] === true;
    });
    if (route) {
      this.runtime.socket._router.stack = this.runtime.socket._router.stack.filter((layer:any) => layer !== route);
    }
    return this;
  }

  public request<T>(url:string):Promise<T> {
    return new Promise<T>((resolve:Function, reject:Function) => {
      fetch(url)
        .then(response => {
          if (!response.ok) {
            throw new Error(`request failed with status: ${response.status}`);
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

  public post<T>(url:string, data:any):Promise<T> {
    return new Promise<T>((resolve, reject) => {
      fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(data)
      })
        .then(response => {
          if (!response.ok) {
            throw new Error(`request failed with status: ${response.status}`);
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
}