import {InternalNetwork} from "./InternalNetwork.js";

export class CrossNetworkToolkit {
  public route(eventName: string, internalNetworkA: InternalNetwork, internalNetworkB: InternalNetwork) {
    internalNetworkA.addListener(eventName, () => {
      internalNetworkB.emit(eventName);
    });
  }
}