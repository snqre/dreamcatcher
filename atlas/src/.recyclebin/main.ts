import * as expressModule from "express";
import * as httpModule from "http";
import * as eventsModule from "events";

/**                                                                                                                                                                                        
    88                                                                       88     888b      88                                                                    88                    
    88                ,d                                                     88     8888b     88                ,d                                                  88                    
    88                88                                                     88     88 `8b    88                88                                                  88                    
    88  8b,dPPYba,  MM88MMM  ,adPPYba,  8b,dPPYba,  8b,dPPYba,   ,adPPYYba,  88     88  `8b   88   ,adPPYba,  MM88MMM  8b      db      d8   ,adPPYba,   8b,dPPYba,  88   ,d8   ,adPPYba,  
    88  88P'   `"8a   88    a8P_____88  88P'   "Y8  88P'   `"8a  ""     `Y8  88     88   `8b  88  a8P_____88    88     `8b    d88b    d8'  a8"     "8a  88P'   "Y8  88 ,a8"    I8[    ""  
    88  88       88   88    8PP"""""""  88          88       88  ,adPPPPP88  88     88    `8b 88  8PP"""""""    88      `8b  d8'`8b  d8'   8b       d8  88          8888[       `"Y8ba,   
    88  88       88   88,   "8b,   ,aa  88          88       88  88,    ,88  88     88     `8888  "8b,   ,aa    88,      `8bd8'  `8bd8'    "8a,   ,a8"  88          88`"Yba,   aa    ]8I  
    88  88       88   "Y888  `"Ybbd8"'  88          88       88  `"8bbdP"Y8  88     88      `888   `"Ybbd8"'    "Y888      YP      YP       `"YbbdP"'   88          88   `Y8a  `"YbbdP"'                                                                                                                                                                                                                                                                                                                                                                       
 */

class InternalNetwork extends eventsModule.EventEmitter {
    public constructor() {
        super();
    }
}

const middlewareInternalNetwork = () => new InternalNetwork();

const coreInternalNetwork = () => new InternalNetwork();

/**                                                                                                                         
    88b           d88  88           88           88  88                                                                      
    888b         d888  ""           88           88  88                                                                      
    88`8b       d8'88               88           88  88                                                                      
    88 `8b     d8' 88  88   ,adPPYb,88   ,adPPYb,88  88   ,adPPYba,  8b      db      d8  ,adPPYYba,  8b,dPPYba,   ,adPPYba,  
    88  `8b   d8'  88  88  a8"    `Y88  a8"    `Y88  88  a8P_____88  `8b    d88b    d8'  ""     `Y8  88P'   "Y8  a8P_____88  
    88   `8b d8'   88  88  8b       88  8b       88  88  8PP"""""""   `8b  d8'`8b  d8'   ,adPPPPP88  88          8PP"""""""  
    88    `888'    88  88  "8a,   ,d88  "8a,   ,d88  88  "8b,   ,aa    `8bd8'  `8bd8'    88,    ,88  88          "8b,   ,aa  
    88     `8'     88  88   `"8bbdP"Y8   `"8bbdP"Y8  88   `"Ybbd8"'      YP      YP      `"8bbdP"Y8  88           `"Ybbd8"'                                                                                                                                                                                                                                   
 */

class NetworkMiddleware {
    private server: httpModule.Server | undefined;

    public connect(port: number): this {
        this.server = expressModule.application.listen(port);
        middlewareInternalNetwork().emit("NETWORK_MIDDLEWARE_CONNECT", {instance: this, port: port});
        return this;
    }

    public disconnect(): this {
        if (this.server) {
            this.server.close();
        }
        middlewareInternalNetwork().emit("NETWORK_MIDDLEWARE_DISCONNECT", {instance: this});
        return this;
    }

    public reconnect(port: number): this {
        this.disconnect();
        this.connect(port);
        middlewareInternalNetwork().emit("NETWORK_MIDDLEWARE_RECONNECT", {instance: this, port: port})
        return this;
    }

    public openPublicEndpoint(endpoint: string, task: (request: expressModule.Request, response: expressModule.Response) => void): this {
        expressModule.application["get"](endpoint, task);
        return this;
    }

    public openPrivateEndpoint(endpoint: string, task: (request: expressModule.Request, response: expressModule.Response) => void): this {
        expressModule.application["post"](endpoint, task);
        return this;
    }

    public closePublicEndpoint(endpoint: string): this {
        let route = expressModule.application._router.stack.find((layer: any): boolean => {
            return layer.route?.endpoint === endpoint && layer.route?.methods["get"] === true;
        });
        if (route) {
            expressModule.application._router.stack = expressModule.application._router.stack.filter((layer: any): any => layer !== expressModule.application._router.stack.find((layer: any): boolean => {
                return layer.route?.endpoint === endpoint && layer.route?.methods["get"] === true;
            }));
        }
        return this;
    }

    public closePrivateEndpoint(endpoint: string): this {
        let route = expressModule.application._router.stack.find((layer: any): boolean => {
            return layer.route?.endpoint === endpoint && layer.route?.methods["post"] === true;
        });
        if (route) {
            expressModule.application._router.stack = expressModule.application._router.stack.filter((layer: any): any => layer !== expressModule.application._router.stack.find((layer: any): boolean => {
                return layer.route?.endpoint === endpoint && layer.route?.methods["post"] === true;
            }));
        }
        return this; 
    }

    public openTimedPublicEndpoint(endpoint: string, closeAfterMs: number, task: (request: expressModule.Request, response: expressModule.Response) => void): this {
        this.openPublicEndpoint(endpoint, task);
        setTimeout((): void => {
            this.closePublicEndpoint(endpoint);
        }, closeAfterMs);
        return this;
    }

    public openTimedPrivateEndpoint(endpoint: string, closeAfterMs: number, task: (request: expressModule.Request, response: expressModule.Response) => void): this {
        this.openPrivateEndpoint(endpoint, task);
        setTimeout((): void => {
            this.closePrivateEndpoint(endpoint);
        }, closeAfterMs);
        return this;
    }

    public request = <T>(url: string): Promise<T> => {
        return new Promise<T>((resolve: (value: T | PromiseLike<T>) => void, reject: (reason?: any) => void): any => {
            
        });
    }
}

const networkMiddleware = () => new NetworkMiddleware();

/**                                          
    88b           d88              88               
    888b         d888              ""               
    88`8b       d8'88                               
    88 `8b     d8' 88  ,adPPYYba,  88  8b,dPPYba,   
    88  `8b   d8'  88  ""     `Y8  88  88P'   `"8a  
    88   `8b d8'   88  ,adPPPPP88  88  88       88  
    88    `888'    88  88,    ,88  88  88       88  
    88     `8'     88  `"8bbdP"Y8  88  88       88  
 */

function main() {
    networkMiddleware().openPrivateEndpoint("/", () => {});
    networkMiddleware().connect(6000);

  networkMiddleware()
    .openPublicEndpoint("/", (request, response) => {
        response.send("WORK_IN_PROGRESS");
    })
    .connect(6969);
}

main();