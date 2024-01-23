import cryptography from 'crypto';
import readline from 'readline';

let terminal = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

class Authenticator {
  runtime:any;
  constructor() {
    this.runtime = {
      access: cryptography.Hash,
      
    }
  }

  access():string {
    return this.runtime.access;
  }

  isValidHash(input:string):boolean {
    let hash:cryptography.Hash = cryptography
      .createHash('sha256')
      .update(input);
    return hash === this.runtime.access;
  }

  requestRuntimeAccessSeed():this {
    terminal.question('please enter runtime access seed: ', (input) => {
      console.log('runtime seed received.');
      this.runtime.access = cryptography
        .createHash('sha256')
        .update(this.runtime.access);
      terminal.close();
    })
    return this;
  }
}

import * as express from "express";

class Connection {
  private runtime:any;
  constructor() {
    this.runtime = {
      socket: express(),
      port: 8000,
      routes: new Map<string, express.IRouterMatcher<express.Express>>()
    };
  }

  socket():express.Express {
    return this.runtime.socket;
  }

  port():number {
    return this.runtime.port;
  }

  restartSocket():this {
    this.runtime.socket = express();
    return this;
  }

  setPort(port:number):this {
    this.runtime.port = port;
    return this;
  }

  createPathOut(path:string, logic:(request:express.Request, response:express.Response)=>void):this {
    let route:any = this.runtime.socket["get"](path, logic);
    this.runtime.routes.set(`get:${path}`, route);
    return this;
  }

  createPathIn(path:string, logic:(request:express.Request, response:express.Response)=>void):this {
    let route:any = this.runtime.socket["post"](path, logic);
    this.runtime.routes.set(`post:${path}`, route);
    return this;
  }

  deletePathOut(path:string):this {
    let key = `get:${path}`;
    let route = this.runtime.routes.get(key);
    if (route) {
      this.runtime.socket._router.stack = this.runtime.socket._router.stack.filter((layer:any) => {
        return layer.route?.path !== path || layer.route?.methods["get"] !== true;
      });
      this.runtime.routes.delete(key);
    }
    return this;
  }

  deletePathIn(path:string):this {
    let key = `post:${path}`;
    let route = this.runtime.routes.get(key);
    if (route) {
      this.runtime.socket._router.stack = this.runtime.socket._router.stack.filter((layer:any) => {
        return layer.route?.path !== path || layer.route?.methods["post"] !== true;
      });
      this.runtime.routes.delete(key);
    }
    return this;
  }

  createTimedPathIn(path:string, logic:(request:express.Request, response:express.Response)=>void, duration:number):this {
    this.createPathIn(path, logic);
    setTimeout(() => {
      this.deletePathIn(path);
    }, duration);
    return this;
  }

  createTimedPathOut(path:string, logic:(request:express.Request, response:express.Response)=>void, duration:number):this {
    this.createPathOut(path, logic);
    setTimeout(() => {
      this.deletePathOut(path);
    }, duration);
    return this;
  }  

  deploy():this {
    this.runtime.socket.listen(this.runtime.port, () => {
      console.log(`connection is running at http://localhost:${this.runtime.port}`);
    });
    return this;
  }
}

let connection:Connection = new Connection()
  .setPort(3000)
  .restartSocket()
  .deploy()
  .createPathOut("/", (request, response) => {
    console.log("HelloWorld");
  });
