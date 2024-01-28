import express, {Express, Router, Request, Response, NextFunction} from "express";
import {Server} from "http";
import {rateLimit} from "express-rate-limit";
import {INTERNAL_NETWORK} from "../internal-network/internal-network.js";

export interface Network {
  application: () => Express;
  router: () => Router;
  activePublicEndpoints: () => string[];
  activePrivateEndpoints: () => string[];
  rateLimitWindowMs: () => number;
  rateLimitMaxRequestsPerWindowMs: () => number;
  rateLimitMessage: () => string;
  server: () => Server | undefined;
  isConnected: () => boolean;
  isInDebugMode: () => boolean;
  port: () => number;
  setPort: (port: number) => Network;
  enableDebugMode: () => Network;
  disableDebugMode: () => Network;
  openPublicEndpoint: (endpoint: string, callback: (request: Request, response: Response) => void) => Network;
  openPrivateEndpoint: (endpoint: string, callback: (request: Request, response: Response) => void) => Network;
  openLockedEndpoint: (endpoint: string, key: string, callback: (request: Request, response: Response) => void) => Network;
  closePublicEndpoint: (endpoint: string) => Network;
  closePrivateEndpoint: (endpoint: string) => Network;
  connect: () => Network;
  unsafeConnect: () => Network;
  disconnect: () => Network;
  unsafeDisconnect: () => Network;
  reconnect: () => Network;
}

export const NETWORK: () => Network = (function(): () => Network {
  let _instance: Network;

  function blueprint(): Network {
    INTERNAL_NETWORK()
      .emit("NETWORK_MIDDLEWARE::DEPLOYED");

    const _APPLICATION: Express = express();
    const _ROUTER: Router = Router();
    const _ACTIVE_PUBLIC_ENDPOINTS: string[] = [];
    const _ACTIVE_PRIVATE_ENDPOINTS: string[] = [];
    let _server: Server | undefined;
    let _port: number; /// WARNING Must be defined before connecting.
    let _isInDebugMode: boolean = false;
    
    function application(): Express {
      return _APPLICATION;
    }

    function router(): Router {
      return _ROUTER;
    }

    function activePublicEndpoints(): string[] {
      return _ACTIVE_PUBLIC_ENDPOINTS;
    }

    function activePrivateEndpoints(): string[] {
      return _ACTIVE_PRIVATE_ENDPOINTS;
    }

    function rateLimitWindowMs(): number {
      return 60_000;
    }

    function rateLimitMaxRequestsPerWindowMs(): number {
      return 100;
    }

    function rateLimitMessage(): string {
      return "Too many requests from this IP, please try again later";
    }

    function server(): Server | undefined {
      return _server;
    }

    function isConnected(): boolean {
      if (server()) {
        return true;
      }
      return false;
    }

    function port(): number {
      return _port;
    }

    function isInDebugMode(): boolean {
      return _isInDebugMode;
    }

    function setPort(port: number): Network {
      _port = port;
      return _instance;
    }

    function enableDebugMode(): Network {
      _isInDebugMode = true;
      return _instance;
    }

    function disableDebugMode(): Network {
      _isInDebugMode = false;
      return _instance;
    }

    function openPublicEndpoint(endpoint: string, callback: (request: Request, response: Response) => void): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::OPENING_PUBLIC_ENDPOINT", {
          endpoint: endpoint,
          callback: callback
        });
      /// WARNING Bypassing type checking here.
      (router() as any)["get"](endpoint, callback);
      activePublicEndpoints().push(endpoint);
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::OPENED_PUBLIC_ENDPOINT", {
          endpoint: endpoint,
          callback: callback
        });
      return _instance;
    }

    function openPrivateEndpoint(endpoint: string, callback: (request: Request, response: Response) => void): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::OPENING_PRIVATE_ENDPOINT", {
          endpoint: endpoint,
          callback: callback
        });
      /// WARNING Bypassing type checking here.
      (router() as any)["post"](endpoint, callback);
      activePrivateEndpoints().push(endpoint);
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::OPENED_PRIVATE_ENDPOINT", {
          endpoint: endpoint,
          callback: callback
        });
      return _instance;
    }

    /// NOTE Locked endpoint is a private endpoint
    function openLockedEndpoint(endpoint: string, key: string, callback: (rquest: Request, response: Response) => void): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::OPENING_LOCKED_PRIVATE_ENDPOINT", {
          endpoint: endpoint,
          key: key,
          callback: callback
        });
      /**
       * WARNING Bypassing type checking here.
       * 
       * Applying authentication request middleware.
       */
      (router() as any)["post"](endpoint, (request: Request, response: Response, next: NextFunction) => _authenticateRequest(key, request, response, next), callback);
      activePrivateEndpoints().push(endpoint);
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::OPENED_LOCKED_PRIVATE_ENDPOINT", {
          endpoint: endpoint,
          key: key,
          callback: callback
        });
      return _instance;
    }

    function closePublicEndpoint(endpoint: string): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::CLOSING_PUBLIC_ENDPOINT", {
          endpoint: endpoint
        });
      const INDEX = activePublicEndpoints().indexOf(endpoint);
      if (INDEX !== -1) {
        router().stack = router().stack.filter(function(layer: any) {
          return layer.route?.path !== endpoint;
        });
        activePublicEndpoints().splice(INDEX, 1);
        INTERNAL_NETWORK()
          .emit("NETWORK_MIDDLEWARE::CLOSED_PUBLIC_ENDPOINT", {
            endpoint: endpoint
          });
        return _instance;
      }
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::COULD_NOT_FIND_ENDPOINT", {
          endpoint: endpoint
        })
      return _instance;
    }

    function closePrivateEndpoint(endpoint: string): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::CLOSING_PRIVATE_ENDPOINT", {
          endpoint: endpoint
        });
      const INDEX = activePrivateEndpoints().indexOf(endpoint);
      if (INDEX !== -1) {
        router().stack = router().stack.filter(function(layer: any) {
          return layer.route?.path !== endpoint;
        });
        activePrivateEndpoints().splice(INDEX, 1);
        INTERNAL_NETWORK()
          .emit("NETWORK_MIDDLEWARE::CLOSED_PRIVATE_ENDPOINT", {
            endpoint: endpoint
          });
        return _instance;
      }
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::COULD_NOT_FIND_ENDPOINT", {
          endpoint: endpoint
        })
      return _instance;
    }

    function connect(): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::CONNECTING");
      _onlyIfNotConnected();
      _onlyIfPortIsNotUndefined();
      unsafeConnect();
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::CONNECTED");
      return _instance
    }

    function unsafeConnect(): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::CONNECTING_VIA_UNSAFE");
      /// WARNING The order of the middleware matters.
      application()
        .use(rateLimit({
          windowMs: rateLimitWindowMs(),
          max: rateLimitMaxRequestsPerWindowMs(),
          message: rateLimitMessage()
        }))
        .use("/", router());
      _server = application().listen(port(), function() {
        /**
        if (isInDebugMode()) {
          console.log(`network middleware connected to `);
        }
        */
        INTERNAL_NETWORK()
          .emit("NETWORK_MIDDLEWARE::CONNECTED_VIA_UNSAFE", {
            url: `http://localhost:${port()}`
          });
      });
      return _instance;
    }

    function disconnect(): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::DISCONNECTING");
      _onlyIfConnected();
      /// NOTE **server** cannot be undefined at this point.
      unsafeDisconnect();
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::DISCONNECTED");
      return _instance;
    }

    function unsafeDisconnect(): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::DISCONNECTING_VIA_UNSAFE")
      server()!.close(function() {
        _server = undefined;
      });
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::DISCONNECTED_VIA_UNSAFE");
      return _instance;
    }

    function reconnect(): Network {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::RECONNECTING");
      disconnect();
      connect();
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::RECONNECTED");
      return _instance;
    }

    function _onlyIfPortIsNotUndefined(): Network {
      if (port()) {
        return _instance;
      }
      throw new Error("PORT_IS_UNDEFINED");
    }

    function _onlyIfNotConnected(): Network {
      if (!isConnected()) {
        return _instance;
      }
      throw new Error("IS_CONNECTED");
    }

    function _onlyIfConnected(): Network {
      if (isConnected()) {
        return _instance;
      }
      throw new Error("IS_CONNECTED");
    }

    function _authenticateRequest(key: string, request: Request, response: Response, next: NextFunction): Response<any, Record<string, any>> | undefined {
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::AUTHENTICATING_REQUEST", {
          key: key,
          request: request,
          response: response,
          next: next
        });
      const KEY = request.headers["key"];
      if (KEY !== key) {
        INTERNAL_NETWORK()
          .emit("NETWORK_MIDDLEWARE::UNAUTHORIZED_REQUEST_REJECTED", {
            correctKey: key,
            givenKey: KEY,
            request,
            response,
            next
          });
        return response
          .status(401)
          .json({error: "UNAUTHORIZED"});
      }
      INTERNAL_NETWORK()
        .emit("NETWORK_MIDDLEWARE::AUTHENTICATED_REQUEST", {
          correctKey: key,
          givenKey: KEY,
          request,
          response,
          next
        });
      /// NOTE Key is has been verified, continue.
      next();
    }

    return {
      application,
      router,
      activePublicEndpoints,
      activePrivateEndpoints,
      rateLimitWindowMs,
      rateLimitMaxRequestsPerWindowMs,
      rateLimitMessage,
      server,
      isConnected,
      isInDebugMode,
      port,
      setPort,
      enableDebugMode,
      disableDebugMode,
      openPublicEndpoint,
      openPrivateEndpoint,
      openLockedEndpoint,
      closePublicEndpoint,
      closePrivateEndpoint,
      connect,
      unsafeConnect,
      disconnect,
      unsafeDisconnect,
      reconnect
    }
  }

  return function(): Network {
    if (!_instance) {
      _instance = blueprint();
    }
    return _instance;
  }
})();

NETWORK()
  .setPort(2000)
  .connect();