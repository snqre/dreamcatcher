class Message {
  runtime:any
  constructor() {
    this.runtime = {
      from: '',
      to: '',
      content: {},

    }
  }
}

class Stream {
  runtime: any;

  constructor() {
    this.runtime = {
      stream: [] // Initialize as an empty array
    };
  }

  stream(position?: number): any {
    position = position === undefined ? 0 : position;
    return this.runtime.stream[position];
  }

  emit(data?: any, position?: number): this {
    if (position === undefined) {
      this.runtime.stream.push(data);
      return this;
    }
    this.runtime.stream[position] = data;
    return this;
  }
}

let stream: Stream = new Stream();

class Consumer {
  runtime: any;

  constructor(position?: number) {
    this.runtime = {
      cursor: {
        position: position === undefined ? 0 : position,
        lastResponse: undefined
      }
    };
  }

  lastResponse(): any {
    return this.runtime.cursor.lastResponse;
  }

  consume(): this {
    this.runtime.cursor.lastResponse = stream.stream(this.runtime.cursor.position);
    this.runtime.cursor.position += 1;
    return this;
  }

  emit(data: any): this {
    stream.emit(data);
    return this;
  }
}

class Op {
  runtime: any;

  constructor() {
    this.runtime = {
      consumers: []
    };
  }

  generateConsumer() {
    this.runtime.consumers.push(new Consumer());
    return this.runtime.consumers[this.runtime.consumers.length - 1];
  }

  runConsumers() {
    this.runtime.consumers.forEach(consumer => {
      consumer
        .consume()
        .process()
        .lastResponse()
    });
  }
}

let op: Op = new Op();
let gen: Consumer = op
  .generateConsumer()
  .emit({ x: 595 })
  .emit({ y: 284 });
let genY: Consumer = op
  .generateConsumer()
  .consume()
  .consume();
console.log(genY.lastResponse());
genY
  .emit({z: 284})
console.log(
  gen
    .consume()
    .consume()
    .lastResponse()
);

while (true) {
  op.runConsumers()
}