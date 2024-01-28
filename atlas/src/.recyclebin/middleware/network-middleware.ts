import {application, Router, Request, Response} from "express";
import {Server} from "http";

let _server: Server;

export const server = (): Server => {
    return _server;
}

export const openPublicEndpoint = (endpoint: string, callback: (request: Request, response: Response) => void): boolean => {
    application["get"](endpoint, callback);
    return true;
}

export const openPrivateEndpoint = (endpoint: string, callback: (request: Request, response: Response) => void): boolean => {
    application["post"](endpoint, callback);
    return true;
}

export const closePublicEndpoint = (endpoint: string): boolean => {
    if (application._router.stack.find((layer: any): boolean => {
        return layer.route?.endpoint === endpoint && layer.route?.methods["get"] === true;
    })) {
        application._router.stack = application._router.stack.filter((layer: any): any => layer !== application._router.stack.find((layer: any): boolean => {
            return layer.route?.endpoint === endpoint && layer.route?.methods["get"] === true;
        }));
    }
    return true;
}

export const closePrivateEndpoint = (endpoint: string): boolean => {
    if (application._router.stack.find((layer: any): boolean => {
        return layer.route?.endpoint === endpoint && layer.route?.methods["post"] === true;
    })) {
        application._router.stack = application._router.stack.filter((layer: any): any => layer !== application._router.stack.find((layer: any): boolean => {
            return layer.route?.endpoint === endpoint && layer.route?.methods["post"] === true;
        }));
    }
    return true;
}

export const openTimedPublicEndpoint = (endpoint: string, closeAfterMs: number, callback: (request: Request, response: Response) => void): boolean => {
    openPublicEndpoint(endpoint, callback);
    setTimeout((): void => {
        closePublicEndpoint(endpoint);
    }, closeAfterMs);
    return true;
}

export const openTimedPrivateEndpoint = (endpoint: string, closeAfterMs: number, callback: (request: Request, response: Response) => void): boolean => {
    openPrivateEndpoint(endpoint, callback);
    setTimeout((): void => {
        closePrivateEndpoint(endpoint);
    }, closeAfterMs);
    return true;
}
