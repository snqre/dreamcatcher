class Operator {
  runtime:any;
  constructor() {
    this.runtime = {
      consumers: []
    };
  }

  assignConsumer():Consumer {
    this.runtime.consumers.push(new Consumer());
    return this.runtime.consumers[this.runtime.consumers.length - 1];
  }

  run():this {
    this.runtime.consumers.forEach(
      consumer => {
        consumer.process();
      }
    );
    return this;
  }
}