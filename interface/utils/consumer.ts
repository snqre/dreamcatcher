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

  response():any {
    return this.runtime.cursor.response;
  }

  consume(stream:Stream):this {
    this.runtime.pointer.response = stream.read(
      this.runtime.pointer.position
    );
    return this;
  }

  process(logic:()=>void):this {
    logic();
    return this;
  }
}