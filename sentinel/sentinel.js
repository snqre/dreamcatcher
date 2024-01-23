const crypto = require('crypto');
const { type } = require('os');

class Type {
    constructor() {
        this._data;
        this._type;
    }

    assign(input) {
        let isSameType = this._type === typeof input;
        if (isSameType) {
            this._data = input;
            return this;
        }
        return this;
    }

    assignToString(data) {
        if (data === "") {
            this._data = data;
            return this;
        }
        return this;
    }

    assignToNumber(data) {

    }

    hash() {
        const hash = crypto.createHash('sha256');
        hash.update(this._data);
        return this;
    }

    fuck() {
        /// does nothing but will express frustration
        return this;
    }
}

let x = new Type()
    .assignToString("Hello");


function createHash(data) {
    const hash = crypto.createHash('sha256');
    hash.update(data);
    return hash.digest('hex');
}

console.log(createHash("Hello"));
console.log(createHash("Hello"));
console.log(createHash("Hi"));

class Block {
    constructor() {
        this.messageString;
        this.contentObject;
        this.opcodeFuncArray;
    }

    message() {
        return this.messageString;
    }

    content() {
        return this.contentObject;
    }

    opcode(positionIntInput) {
        return this.opcodeFuncArray[positionIntInput];
    }
}

class Stream {
    constructor() {
        this
            .myStream = [];
    }

    emit(
        message_, 
        content_={}, 
        opcode_=[]
    ) {
        let stack = new Error()
            .stack
            .split('\n')
            [2]
            .match(/at (.+) \((.+):(\d+):(\d+)\)/);
        this
            .myStream
            .push({
                from:        stack[1],
                fromUrl: "",
                path:        stack[2],
                line:        stack[3],
                column:      stack[4],
                timestamp:   new Date()
                    .toDateString(),
                message:     message_,
                content:     content_,
                opcode:      opcode_
            });
        return this;
    }

    read(position) {
        return this
            .myStream
            [position];
    }
}

class Consumer {
    constructor() {
        this._currentPosition = 0;
        this._lastMessage = "";
        this._response = new Map();
    }

    currentPosition() {
        return this._currentPosition;
    }

    lastMessage() {
        return this._lastMessage;
    }

    response(message) {
        return this._response.get(message);
    }

    setCurrentPosition(position) {
        this._currentPosition = position;
        return this;
    }

    tryToExecute() {

    }

    consume(stream) {
        let message = stream.read(this.currentPosition());
        this._lastMessage = message;
        if (this._response.get(message)) {
            this.response(message)();
        }
        this._currentPosition += 1;
        return this;
    }
}

let stream = new Stream()
    .emit("")
    .emit("")
    .emit("")

function test() {
    stream
        .emit("HelloWorld");
}

test();

console
    .log(stream.read(3));