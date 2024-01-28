import {EventEmitter} from "events";
import {application, Router, Request, Response} from "express";
import express from "express";
import {Server} from "http";




/// be able to pull data from onchain to program

class InternalNetwork extends EventEmitter {
  constructor() {
    super();
  }
}

class InternalResponder {
  State = {
    0: "idle",
    1: "processing-queue"
  }

  queue: object[] = [];

  public constructor(request: string) {
    /// when the responder is processing and receives another request
    /// it will be added to a queue
    /// after all the queue is over it will become idle

    /// will either return failed request back or success 200 or 404
  }
}

class InternalRequester {
  State = {
    0: "idle",
    1: "sent-out-a-request",
    2: "waiting-for-correct-response",
    3: "request-has-been-fullfilled", /// request either goes fulfilled
    4: "request-has-timed-out",  /// or becomes outdated and times out
    5: 2,
    6: 3,
    7: 4,
    49: 4,
    50: 3,
    51: 2,
    1284: 2,
    
  }

  public constructor(request: string, args: object) {
    internalNetwork.emit(request, args);


  }
}

const internalNetwork = new InternalNetwork(); /// queable emissions??

/// we need a router to route emissions from IN to TN terminal network
/// and vice versa to integrate external microservices
/// thse will have to be authenticated

internalNetwork.on("pulse", () => {
  console.log("pulse");
});

setInterval(function() {
  internalNetwork.emit("pulse");
}, 30000);

class ShellMiddleware {
  queue: string[];

  public constructor() {
    this.queue = [];
  }
}

class NetworkMiddleware {

}

class FileHandlerMiddleware {

}
 
class PolygonMiddleware {

}



/// not working?? maybe proxy connection issues
application["get"]("/", function(request, response) {
  response.send("coming-soon");
  console.log("Hello");

  internalNetwork.emit("return-address-data-request", {});

  internalNetwork.on("return-address-data-request", function(content) {
    response.send(content);

    if (true) {
      internalNetwork.removeAllListeners("return-address-data-request");
    }
  })

  internalNetwork.emit("network-private-endpoint-triggered", {request, response});
})

application.listen(3000, function() {
  console.log(`http://localhost:${3000}`);
});



internalNetwork.on("address-data-request", (content) => {
  /// fetch web3 data based on request
  

  internalNetwork.emit("return-address-data-request", {
    status: 200,
    price: 24.83,
    name: "HelloWorld"
  });
})

