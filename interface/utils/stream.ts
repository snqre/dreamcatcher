class Stream {
  runtime:any;
  constructor() {
    this.runtime = {
      stream: []
    }
  }

  read(position?:number):this {
    position = position === undefined ? 0 : position;
    return this.runtime.stream[position];
  }

  emit(opcode?:any, position?:number):this {
    opcode = opcode === undefined ? {} : opcode;
    if (position === undefined) {
      this.runtime.stream.push(opcode);
      return this;
    }
    this.runtime.stream[position] = opcode;
    return this;
  }
}