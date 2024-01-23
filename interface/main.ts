class Message {
  runtime:any;
  constructor() {
    this.runtime = {
      from: '',
      to: '',
      content: {}
    };
  }

  from():string {
    return this.runtime.from;
  }

  to():string {
    return this.runtime.to;
  }

  content():any {
    return this.runtime.content;
  }

  sendFrom(from:string):this {
    this.runtime.from = from;
    return this;
  }

  sendTo(to:string):this {
    this.runtime.to = to;
    return this;
  }

  pack(content:any):this {
    this.runtime.content = content;
    return this;
  }
}

class Stream {
  runtime:any;
  constructor() {
    this.runtime = {
      stream: []
    };
  }

  read(position?:number):this {
    return this.runtime.stream[position === undefined ? 0 : position];
  }

  emit(message:Message, position?:number):this {
    this.runtime.stream[position === undefined ? 0 : position] = message;
    return this;
  }
}

class Consumer {
  runtime:any;
  constructor(position?:number) {
    this.runtime = {
      pointer: {
        position: position === undefined ? 0 : position,
        response: undefined
      }
    }
  }

  position():number {
    return this.runtime.pointer.position;
  }

  response():any {
    return this.runtime.pointer.response;
  }

  consume(stream:Stream, position?:number):this {
    this.runtime.pointer.response = stream.read(position === undefined ? this.runtime.pointer.position : position);
    this.runtime.pointer.position += position === undefined ? 1 : 0;
    return this;
  }
}

class Operator {
  runtime:any;
  constructor() {
    this.runtime = {
      stream: new Stream(),
      consumers: [],
      running: false,
    }
  }

  readFromStream(position?:number):Message {
    return this.runtime.stream.read(position === undefined ? 0 : position);
  }

  generateConsumer(processBackLog:boolean=false) {
    this.runtime.consumers.push(
      new Consumer( /// process stream from the start or goto recent position
        processBackLog ? 0 : this.runtime.stream.length
      )
    );
    /// return copy of the runtime consumer
    return this.runtime.consumers[this.runtime.consumers.length - 1];
  }

  running():boolean {
    return this.runtime.running;
  }

  emitToStream(message:Message):this {
    this.runtime.stream.emit(message);
    return this;
  }

  switchOn():this {
    this.runtime.running = true;
    return this;
  }

  switchOff():this {
    this.runtime.running = false;
    return this;
  }
}

function main():void {
  let operator:Operator = new Operator()
    .switchOn()
    .emitToStream(
      new Message()
        .sendFrom('<operator>')
        .sendTo('<everyone>')
        .pack({
          message: 'SysInitMessage'
        })
    );

  
  
  while (operator.running()) {
    for (let i = 0; i < operator.runtime.consumers.length; i++) {
      let consumer = operator.runtime.consumers[i];
      console.log(
        consumer
          .consume()
          .response()
      );
    }

    console.log('running');

    operator.switchOff();
  }
}

main();