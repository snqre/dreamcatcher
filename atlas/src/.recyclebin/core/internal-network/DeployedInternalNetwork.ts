import {InternalNetwork} from "./blueprint/InternalNetwork.js";
import {CrossNetworkToolkit} from "./blueprint/CrossNetworkToolkit.js";

export const kernelClusterNetwork = (() => new InternalNetwork());

export const middlewareClusterNetwork = (() => new InternalNetwork());

export const crossNetworkToolkit = (() => new CrossNetworkToolkit());