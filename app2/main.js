class FileManager {
    constructor() {
        this._path = "";
        this._response = "";
        this.fs = require("fs");
    }

    path() {
        return this._path;
    }

    setPath(path) {
        this._path = path;
        return this;
    }

    response() {
        return this._response;
    }

    setResponse(response) {
        this._response = response;
        return this;
    }

    open() {
        return this
            .fs
            .readFile(this.path());
    }

    expect() {
        this.response() ===  
    }
}

let manager = new FileManager()
    .setPath("helloWorld.text")
    .setResponse("HelloWorld")
    .open()
    .expect();